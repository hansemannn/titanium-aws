var AWS = require('ti.aws');

var win = Ti.UI.createWindow({ backgroundColor: '#fff' });
var button = Ti.UI.createButton({ title: 'Upload' });


var transferManager = AWS.createS3TransferManager();
transferManager.configure({
    region: AWS.REGION_US_WEST_1,
    poolId: 'YOUR_POOL_ID'
});

button.addEventListener('click', function () {
    var file = Ti.Filesystem.getFile(Ti.Filesystem.resourcesDirectory, 'example.png');
    console.log(file.nativePath)
    
    if (!file.exists()) {
        throw new Error('NO SUCH FILE');
    }
    
    transferManager.upload({
        file: file.nativePath,
        bucket: 'lambus',
        key: 'profiles/example-' + new Date().getTime() + '.png',
        success: function (event) {
            Ti.API.warn('SUCCESS!');
            Ti.API.warn(event);
        },
        error: function (event) {
            Ti.API.error('ERROR!');
            Ti.API.error(event);
        }
    });    
});

win.add(button);
win.open();