#!/usr/bin/env node

var fs = require('fs');
var path = require('path');
var compresser = require('../compresser.js')

var rootPath = process.argv[2] || process.cwd();
var options = {};

if (fs.existsSync(path.join(rootPath, '.compresser'))) {
    var compresser_opts = fs.readFileSync(path.join(rootPath, '.compresser'), 'utf-8');
    compresser_opts = compresser_opts.split('\n')
    var compresser_opt = null;
    for (_i = 0, _len = compresser_opts.length; _i < _len; _i++) {
        compresser_opt = compresser_opts[_i];
        compresser_opt = compresser_opt.split(':');
        options[compresser_opt[0]] = compresser_opt[1].trim().split('|')
    }
}


options.rootPath = rootPath

// console.log(options)
compresser.compress(options)
