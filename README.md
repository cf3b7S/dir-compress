dir-compress
============
### about
dir-compress use [uglify-js](https://github.com/mishoo/UglifyJS2) to you compress you entire project 

### how to use
```
npm install dir-compress
```

```
var compresser = require('dir-compress');
compresser.compress({
    rootPath: 'folder want to be compressed',
    newRootPath: 'new dir root',
    exclude: ['/folder'] //this path is relative to rootPath, which will not be compressed
})
```

if you use coffee, dir-compress will automatic remove the coffee files

