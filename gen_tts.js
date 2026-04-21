const edgeTts = require('edge-tts');
const fs = require('fs');
const path = require('path');

async function main() {
    const output = 'C:\\Users\\hci\\.openclaw\\workspace\\notification_sound.mp3';
    const tts = new edgeTts.Communication('你干嘛~哎哟~', 'zh-CN-YunxiNeural');
    const stream = await tts.stream();
    
    // Write the stream to file
    const fileStream = fs.createWriteStream(output);
    stream.pipe(fileStream);
    
    await new Promise((resolve, reject) => {
        fileStream.on('finish', resolve);
        fileStream.on('error', reject);
    });
    
    console.log('Audio saved to: ' + output);
}

main().catch(err => console.error(err));
