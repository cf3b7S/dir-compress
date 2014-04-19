fs = require('fs')
path = require('path')
crypto = require('crypto')


rootPath = '/home/jukin/code/kk/dir-compress/'
md5Path = '/home/jukin/code/kk/dir-compress/upgrade/version/.md5'


getMd5 = (filePath)->
	file = fs.readFileSync(filePath, 'utf-8')
	md5 = crypto.createHash('md5').update(file).digest('hex')
	rpath = path.relative(rootPath, filePath)
	return [rpath, md5]

recordMd5 = (md5)->



coffeePath = '/home/jukin/code/kk/dir-compress/upgrade.coffee'

console.log getMd5(coffeePath)