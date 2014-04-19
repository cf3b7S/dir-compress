compresser = require('./compresser.js')

fs = require('fs')
compresser_opts = fs.readFileSync('/home/jukin/code/weixing/hairdressing/.compresser', 'utf-8')
options = {}
compresser_opts = compresser_opts.split('\n')
for compresser_opt in compresser_opts
	compresser_opt = compresser_opt.split(':')
	options[compresser_opt[0]] = RegExp(compresser_opt[1].trim(), 'g')

options.rootPath = '/home/jukin/code/weixing/hairdressing'



console.log options
compresser.compress(options)