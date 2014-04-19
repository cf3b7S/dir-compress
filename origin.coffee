os =require('os')
path = require('path')
crypto = require('crypto')
async = require('async')
_ = require('underscore')
uglify = require('uglify-js')
fs = require('fs-extra')
exec = require('child_process').exec




rootPath = '/home/jukin/code/weixing/hairdressing'
newRootPath = '/home/jukin/code/_hairdressing'
modulePath = path.join(newRootPath, 'node_modules')
exclude = ['.git']
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

walk = (walkPath)->
	files = isDir(walkPath)
	if files.length
		_.each(files, (file, index)->
			if !~file.indexOf('.') and file != 'node_modules'
				dirPath = path.join(walkPath, file)
				if !~_.indexOf(exclude, dirPath) and isDir(dirPath) # 文件夹
					walk(dirPath)
				else if !isDir(dirPath) # 文件
					console.log dirPath
			else # 文件
				filePath = path.join(walkPath, file)
				console.log file
				console.log getMd5(filePath)

				if ~file.indexOf('.js') and !~file.indexOf('.json') and !~file.indexOf('.min.js')
					jsPath = path.join(walkPath, file)
					jsArr.push(jsPath)
				else if ~file.indexOf('.coffee')
					coffeePath = path.join(walkPath, file)
					fs.removeSync(coffeePath)
		)

getVersion = (rootPath)->
	packagePath = path.join(rootPath, 'package.json')
	pkg = fs.readFileSync(packagePath, 'utf-8')
	pkg = JSON.parse(pkg)
	return pkg.version

getMd5 = (filePath)->
	file = fs.readFileSync(filePath, 'utf-8')
	md5 = crypto.createHash('md5').update(file).digest('hex')
	rpath = path.relative(rootPath, filePath)
	return [rpath, md5]


if fs.existsSync(newRootPath)
	root_v = getVersion(rootPath)
	newRoot_v = getVersion(newRootPath)

	# root_v = '0.0.2'
	if root_v.localeCompare(newRoot_v) # 说明有更新
		upPackagePath = path.join(rootPath, 'upgrade', root_v)
		oldVersionPath = path.join(newRootPath, 'upgrade', newRoot_v)
		md5UP = {}
		console.log '有更新'
	else
		console.log '木有更新'


	console.log '存在'
else
	console.log '不存在'
	fs.copySync(rootPath, newRootPath)
	exec('rm -rf ' + modulePath, (err)->
		if err
			console.log err
	)
	exec('rm -rf ' + modulePath, (err)->
		if err
			console.log err
	)





# fs.copySync(rootPath, newRootPath)
# if os.platform() == 'linux'
# 	exec('rm -rf ' + modulePath, (err)->
# 		if err
# 			console.log err
# 	)

walk(newRootPath)

# async.whilst(
# 	()->
# 		return count < jsArr.length
# 	(cb)->
# 		jsPath = jsArr[count]
# 		minify(jsPath, (err, data)->
# 			if !err and data
# 				fs.writeFile(jsPath, data, (err)->
# 					if err
# 						throw err
# 					else
# 						cb(null)
# 				)
# 			else
# 				console.log(jsPath, ',has sth wrong')
# 				console.log 'try to add the folder to exclude'
# 				throw err
# 		)
# 		count++
# 	(err, result)->
# 		console.log 'finish compress'
# )