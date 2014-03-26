async = require 'async'
_ = require 'underscore'
uglify = require 'uglify-js'
fs = require 'fs-extra'
path = require 'path'
exec = require('child_process').exec
os =require 'os'


module.exports = {
	compress: (options)->
		if options.rootPath and options.newRootPath
			rootPath = options.rootPath
			newRootPath = options.newRootPath
			modulePath = path.join(newRootPath, 'node_modules')
			exclude = options.exclude ? []
			jsArr = []
			count = 0
			
			_.each(exclude, (folder, index)->
				exclude[index] = path.join(newRootPath, folder)
			)
			minify = (pathName, callback)->
				try 
					result = uglify.minify(pathName, {
						# warnings: true,
						mangle: true
					})
					callback(null, result.code)
				catch err
					callback(err)

			isDir = (pathName)->
				try 
					fs.readdirSync(pathName)
				catch err
					if err and err.code == 'ENOTDIR'
						return null
					else
						throw err
			walk = (newRootPath)->
				files = isDir(newRootPath)
				if files.length
					_.each(files, (file, index)->
						if !~file.indexOf('.') and file != 'node_modules'
							dirPath = path.join(newRootPath, file)
							if !~_.indexOf(exclude, dirPath) and isDir(dirPath)
								walk(dirPath)
						else if ~file.indexOf('.js') and !~file.indexOf('.json') and !~file.indexOf('.min.js')
							jsPath = path.join(newRootPath, file)
							jsArr.push(jsPath)
					)

			fs.copySync(rootPath, newRootPath)
			if os.platform() == 'linux'
				exec('rm -rf ' + modulePath, (err)->
					if err
						console.log err
				)

			walk(newRootPath)

			async.whilst(
				()->
					return count < jsArr.length
				,(cb)->
					jsPath = jsArr[count]
					minify(jsPath, (err, data)->
						if !err and data
							fs.writeFile(jsPath, data, (err)->
								if err
									throw err
								else
									cb(null)
							)
						else
							console.log(jsPath, ',has sth wrong')
							console.log 'try to add the folder to exclude'
							throw err
					)
					count++
				,(err, result)->
					console.log 'finish compress'
			)
		else
			console.log '参数错误'
}