path = require('path')
exec = require('child_process').exec
async = require('async')
_ = require('lodash')
uglify = require('uglify-js')
fs = require('fs-extra')

module.exports = {
	compress: (options)->
		if options.rootPath
			rootPath = options.rootPath
			motherPath = path.dirname(rootPath)
			projectName = path.basename(rootPath)
			tarName = projectName + '.tar.gz'
			tarPath = path.join(motherPath, tarName)
			newRootPath = newRootPath or path.join(motherPath, '_' + projectName)

			removeDir = options.removeDir or null
			removeFile = options.removeFile or null
			exclude = options.exclude or null
			active = options.active or null
			console.log 'prepare compress...'
			if fs.existsSync(newRootPath)
				# 询问是否覆盖原来文件夹
				fs.removeSync(newRootPath)
			if fs.existsSync(tarPath)
				fs.removeSync(tarPath)

			fs.copySync(rootPath, newRootPath)

			walk = (walkPath)->
				output = []
				directories = []
				_.each(fs.readdirSync(walkPath), (file, index)->
					newRootPath = path.join(walkPath, file)
					stat = fs.statSync(newRootPath)
					if stat.isFile()
						if removeFile and removeFile.test(file)
							fs.removeSync(newRootPath)
						else if /(.*)\.js$/.test(file)
							output.push(newRootPath)
						else if /(.*)\.coffee$/.test(file)
							fs.removeSync(newRootPath)
					else if stat.isDirectory()
						if removeDir and removeDir.test(file)
							fs.removeSync(newRootPath)
						else if exclude and !exclude.test(file)
							directories.push(newRootPath)
				)
				_.each(directories, (dir, index)->
					output = output.concat(walk(dir))
				)
				return output


			count = 0
			jsArr = walk(newRootPath)
			async.whilst(
				()->
					return count < jsArr.length
				(cb)->
					jsPath = jsArr[count]
					minify(jsPath, (err, data)->
						if !err
							fs.writeFile(jsPath, data, (err)->
								if err
									cb(null)
								else
									console.log jsPath + ' compressed'
									cb(null)
							)
						else
							console.log err
							throw err
							console.log(jsPath, ',has sth wrong, and skiped')
							cb(null)
					)
					count++
				(err, result)->					
					exec('tar -zcvf ' + tarName + ' ' + ('_' + projectName), {cwd: motherPath}, (err)->
						if !err
							exec('scp hairdressing.tar.gz ucloud:/home/ubuntu',{cwd: motherPath}, (err)->
								if !err
									console.log 'upload success'
								else
									console.log err								
							)
						else
							console.log err
					)
					console.log 'finish compress'
			)
		else
			console.log '参数错误'
}


minify = (pathName, callback)->
	try 
		result = uglify.minify(pathName, {
			# warnings: true,
			mangle: true
		})
		callback(null, result.code)
	catch err
		callback(err)
















# walk = (options)->
# 	output = []
# 	directories = []



# 	rootPath = options.rootPath
# 	include = options.include or /(.*)\.js$/
# 	exclude = options.exclude or /node_modules/g
# 	removePath = options.removePath
# 	removeFile = options.removeFile or /(.*)\.coffee$/
# 	removeDir = options.removeDir or /node_modules/g

# 	_.each(fs.readdirSync(rootPath), (file, index)->
# 		newRootPath = path.join(rootPath, file)
# 		stat = fs.statSync(newRootPath)
# 		if stat.isFile()
# 			if include.test(file) and (!exclude or !exclude.test(file))
# 				output.push(newRootPath.replace(removePath, ''))
# 			if removeFile.test(file)
# 				removeFilePath = path.join(rootPath, file)
# 				fs.removeSync(removeFilePath)
# 			return
# 		else if stat.isDirectory()
# 			if removeDir.test(file)
# 				removeDirPath = path.join(rootPath, file)
# 				fs.removeSync(removeDirPath)
# 			if !(exclude and exclude.test(file))
# 				if file == 'public'
# 					console.log exclude and exclude.test(file)
# 					console.log exclude
# 					console.log !exclude
# 					console.log directories
# 				directories.push(newRootPath)
# 				if file == 'public'
# 					console.log directories
# 			return
# 	)
# 	_.each(directories, (dir, index)->
# 		options.rootPath = dir
# 		output = output.concat(walk(options))
# 	)
# 	return output


