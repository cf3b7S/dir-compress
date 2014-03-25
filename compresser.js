var async, exec, fs, os, path, uglify, _;

async = require('async');

_ = require('underscore');

uglify = require('uglify-js');

fs = require('fs-extra');

path = require('path');

exec = require('child_process').exec;

os = require('os');

console.log(os.platform());

module.exports = {
    compress: function(options) {
        var count, exclude, isDir, jsArr, minify, modulePath, newRootPath, rootPath, walk, _ref;
        if (options.rootPath && options.newRootPath) {
            rootPath = options.rootPath;
            newRootPath = options.newRootPath;
            modulePath = path.join(newRootPath, 'node_modules');
            exclude = (_ref = options.exclude) != null ? _ref : [];
            jsArr = [];
            count = 0;
            _.each(exclude, function(folder, index) {
                return exclude[index] = path.join(newRootPath, folder);
            });
            minify = function(pathName, callback) {
                var err, result;
                try {
                    result = uglify.minify(pathName, {
                        mangle: true
                    });
                    return callback(null, result.code);
                } catch (_error) {
                    err = _error;
                    return callback(err);
                }
            };
            isDir = function(pathName) {
                var err;
                try {
                    return fs.readdirSync(pathName);
                } catch (_error) {
                    err = _error;
                    if (err && err.code === 'ENOTDIR') {
                        return null;
                    } else {
                        throw err;
                    }
                }
            };
            walk = function(newRootPath) {
                var files;
                files = isDir(newRootPath);
                if (files.length) {
                    return _.each(files, function(file, index) {
                        var dirPath, jsPath;
                        if (!~file.indexOf('.') && file !== 'node_modules') {
                            dirPath = path.join(newRootPath, file);
                            if (!~_.indexOf(exclude, dirPath) && isDir(dirPath)) {
                                return walk(dirPath);
                            }
                        } else if (~file.indexOf('.js') && !~file.indexOf('.json') && !~file.indexOf('.min.js')) {
                            jsPath = path.join(newRootPath, file);
                            return jsArr.push(jsPath);
                        }
                    });
                }
            };
            fs.copySync(rootPath, newRootPath);
            if (os.platform() === 'linux') {
                exec('rm -rf ' + modulePath, function(err) {
                    if (err) {
                        return console.log(err);
                    }
                });
            }
            walk(newRootPath);
            return async.whilst(function() {
                return count < jsArr.length;
            }, function(cb) {
                var jsPath;
                jsPath = jsArr[count];
                minify(jsPath, function(err, data) {
                    if (!err && data) {
                        return fs.writeFile(jsPath, data, function(err) {
                            if (err) {
                                throw err;
                            } else {
                                return cb(null);
                            }
                        });
                    } else {
                        console.log(jsPath, ',has sth wrong');
                        console.log('try to add the folder to exclude');
                        throw err;
                    }
                });
                return count++;
            }, function(err, result) {
                return console.log('finish compress');
            });
        } else {
            return console.log('参数错误');
        }
    }
};
