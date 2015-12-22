# yourTube
native objective-c wrapper for youtube get_video_info

Instantiate KBYourTube and get video streams in 2 lines of code;

    KBYourTube *tube = [[KBYourTube alloc] init];
    NSArray *streamArray = [tube getVideoStreamsForID:@"_7nYuyfkjCk"];
    
Would yield
    
    2015-12-22 02:07:09.486 yourTube[9239:15831573] streamArray: (
        {
        downloadURL = "https://r15---sn-bvvbax-2iml.googlevideo.com/videoplayback?upn=rfqS32ShGLo&ratebypass=yes&lmt=1417236324599143&key=yt6&itag=22&sparams=dur%2Cid%2Cip%2Cipbits%2Citag%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cnh%2Cpl%2Cratebypass%2Crequiressl%2Csource%2Cupn%2Cexpire&source=youtube&nh=EAI&dur=323.895&sver=3&expire=1450796829&mn=sn-bvvbax-2iml&mm=31&pl=16&id=o-AOCRM4CxluaEDjsUPa1mmbqbl55G-pDTx_M3zzY2EUBD&mime=video%2Fmp4&ipbits=0&requiressl=yes&ip=98.165.123.35&mv=m&fexp=9416126%2C9420452%2C9422596%2C9423662%2C9424859&mt=1450775129&ms=au&signature=C9FC0327FEB1402CFA4F6E31E6065AD5F303744F.2AE58012D44EE498514685C1FFF20B4332874CDC&title=Lil+Wayne+-+She+Will+ft.+Drake%20%5B720p%5D";
        "fallback_host" = "tc.v20.cache6.googlevideo.com";
        format = "720p MP4";
        height = 720;
        itag = 22;
        quality = hd720;
        s = "B9F79FC0327FE71402CFA4F6E31E6065AD5F303C44F.2AE58012D44EE498514685C1FFF20B4332874CDCCDC";
        title = "Lil Wayne - She Will ft. Drake";
        type = "video/mp4; codecs=avc1.64001F, mp4a.40.2";
        url = "https://r15---sn-bvvbax-2iml.googlevideo.com/videoplayback?upn=rfqS32ShGLo&ratebypass=yes&lmt=1417236324599143&key=yt6&itag=22&sparams=dur%2Cid%2Cip%2Cipbits%2Citag%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cnh%2Cpl%2Cratebypass%2Crequiressl%2Csource%2Cupn%2Cexpire&source=youtube&nh=EAI&dur=323.895&sver=3&expire=1450796829&mn=sn-bvvbax-2iml&mm=31&pl=16&id=o-AOCRM4CxluaEDjsUPa1mmbqbl55G-pDTx_M3zzY2EUBD&mime=video%2Fmp4&ipbits=0&requiressl=yes&ip=98.165.123.35&mv=m&fexp=9416126%2C9420452%2C9422596%2C9423662%2C9424859&mt=1450775129&ms=au&signature=C9FC0327FEB1402CFA4F6E31E6065AD5F303744F.2AE58012D44EE498514685C1FFF20B4332874CDC";
    },
        {
        downloadURL = "https://r15---sn-bvvbax-2iml.googlevideo.com/videoplayback?upn=rfqS32ShGLo&ratebypass=yes&lmt=1314629037323189&key=yt6&itag=43&sparams=dur%2Cid%2Cip%2Cipbits%2Citag%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cnh%2Cpl%2Cratebypass%2Crequiressl%2Csource%2Cupn%2Cexpire&source=youtube&nh=EAI&dur=0.000&sver=3&expire=1450796829&mn=sn-bvvbax-2iml&mm=31&pl=16&id=o-AOCRM4CxluaEDjsUPa1mmbqbl55G-pDTx_M3zzY2EUBD&mime=video%2Fwebm&ipbits=0&requiressl=yes&ip=98.165.123.35&mv=m&fexp=9416126%2C9420452%2C9422596%2C9423662%2C9424859&mt=1450775129&ms=au&signature=6EB43F51FFB3475F4B1AAC2A40322637860765FD.78A956890B4EA88A76216DE4024F10DB9F105087&title=Lil+Wayne+-+She+Will+ft.+Drake%20%5B360p%5D";
        "fallback_host" = "tc.v6.cache3.googlevideo.com";
        format = "360p WebM";
        height = 360;
        itag = 43;
        quality = medium;
        s = "BEB6EB43F51FF63475F4B1AAC2A40322637860765FD.78A956890B4EA88A76216DE4024F10DB9F105780780";
        title = "Lil Wayne - She Will ft. Drake";
        type = "video/webm; codecs=vp8.0, vorbis";
        url = "https://r15---sn-bvvbax-2iml.googlevideo.com/videoplayback?upn=rfqS32ShGLo&ratebypass=yes&lmt=1314629037323189&key=yt6&itag=43&sparams=dur%2Cid%2Cip%2Cipbits%2Citag%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cnh%2Cpl%2Cratebypass%2Crequiressl%2Csource%2Cupn%2Cexpire&source=youtube&nh=EAI&dur=0.000&sver=3&expire=1450796829&mn=sn-bvvbax-2iml&mm=31&pl=16&id=o-AOCRM4CxluaEDjsUPa1mmbqbl55G-pDTx_M3zzY2EUBD&mime=video%2Fwebm&ipbits=0&requiressl=yes&ip=98.165.123.35&mv=m&fexp=9416126%2C9420452%2C9422596%2C9423662%2C9424859&mt=1450775129&ms=au&signature=6EB43F51FFB3475F4B1AAC2A40322637860765FD.78A956890B4EA88A76216DE4024F10DB9F105087";
    },
        {
        downloadURL = "https://r15---sn-bvvbax-2iml.googlevideo.com/videoplayback?upn=rfqS32ShGLo&ratebypass=yes&lmt=1417236323829380&key=yt6&itag=18&sparams=dur%2Cid%2Cip%2Cipbits%2Citag%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cnh%2Cpl%2Cratebypass%2Crequiressl%2Csource%2Cupn%2Cexpire&source=youtube&nh=EAI&dur=323.895&sver=3&expire=1450796829&mn=sn-bvvbax-2iml&mm=31&pl=16&id=o-AOCRM4CxluaEDjsUPa1mmbqbl55G-pDTx_M3zzY2EUBD&mime=video%2Fmp4&ipbits=0&requiressl=yes&ip=98.165.123.35&mv=m&fexp=9416126%2C9420452%2C9422596%2C9423662%2C9424859&mt=1450775129&ms=au&signature=C4989FBC44A52D5597D83CBAA23F30C4066AA976.B9B0D9ADDDD1E4869AEC93B876DD05853F9B110F&title=Lil+Wayne+-+She+Will+ft.+Drake%20%5B360p%5D";
        "fallback_host" = "tc.v2.cache7.googlevideo.com";
        format = "360p MP4";
        height = 360;
        itag = 18;
        quality = medium;
        s = "A49A4989FBC44A52D5597D83CBAA23F30C4066AC976.B9B0D9ADDDD1E4869AEC93B876DD05853F9B1F01F01";
        title = "Lil Wayne - She Will ft. Drake";
        type = "video/mp4; codecs=avc1.42001E, mp4a.40.2";
        url = "https://r15---sn-bvvbax-2iml.googlevideo.com/videoplayback?upn=rfqS32ShGLo&ratebypass=yes&lmt=1417236323829380&key=yt6&itag=18&sparams=dur%2Cid%2Cip%2Cipbits%2Citag%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cnh%2Cpl%2Cratebypass%2Crequiressl%2Csource%2Cupn%2Cexpire&source=youtube&nh=EAI&dur=323.895&sver=3&expire=1450796829&mn=sn-bvvbax-2iml&mm=31&pl=16&id=o-AOCRM4CxluaEDjsUPa1mmbqbl55G-pDTx_M3zzY2EUBD&mime=video%2Fmp4&ipbits=0&requiressl=yes&ip=98.165.123.35&mv=m&fexp=9416126%2C9420452%2C9422596%2C9423662%2C9424859&mt=1450775129&ms=au&signature=C4989FBC44A52D5597D83CBAA23F30C4066AA976.B9B0D9ADDDD1E4869AEC93B876DD05853F9B110F";
    },
        {
        downloadURL = "https://r15---sn-bvvbax-2iml.googlevideo.com/videoplayback?upn=rfqS32ShGLo&fexp=9416126%2C9420452%2C9422596%2C9423662%2C9424859&dur=323.866&expire=1450796829&sver=3&key=yt6&lmt=1394255591390341&mt=1450775129&mn=sn-bvvbax-2iml&mm=31&pl=16&id=o-AOCRM4CxluaEDjsUPa1mmbqbl55G-pDTx_M3zzY2EUBD&mime=video%2Fx-flv&sparams=dur%2Cid%2Cip%2Cipbits%2Citag%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cnh%2Cpl%2Crequiressl%2Csource%2Cupn%2Cexpire&ipbits=0&requiressl=yes&ip=98.165.123.35&mv=m&itag=5&source=youtube&ms=au&nh=EAI&signature=7E1AF27E05B9A02A11B1A926987C5E30B33C6635.B6629E2B1BE573D872D396E5A4650302581DBCD0&title=Lil+Wayne+-+She+Will+ft.+Drake%20%5B240p%5D";
        "fallback_host" = "tc.v5.cache6.googlevideo.com";
        format = "240p FLV";
        height = 240;
        itag = 5;
        quality = small;
        s = "BE16E1AF27E0569A02A11B1A926987C5E30B33C7635.B6629E2B1BE573D872D396E5A4650302581DB0DC0DC";
        title = "Lil Wayne - She Will ft. Drake";
        type = "video/x-flv";
        url = "https://r15---sn-bvvbax-2iml.googlevideo.com/videoplayback?upn=rfqS32ShGLo&fexp=9416126%2C9420452%2C9422596%2C9423662%2C9424859&dur=323.866&expire=1450796829&sver=3&key=yt6&lmt=1394255591390341&mt=1450775129&mn=sn-bvvbax-2iml&mm=31&pl=16&id=o-AOCRM4CxluaEDjsUPa1mmbqbl55G-pDTx_M3zzY2EUBD&mime=video%2Fx-flv&sparams=dur%2Cid%2Cip%2Cipbits%2Citag%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cnh%2Cpl%2Crequiressl%2Csource%2Cupn%2Cexpire&ipbits=0&requiressl=yes&ip=98.165.123.35&mv=m&itag=5&source=youtube&ms=au&nh=EAI&signature=7E1AF27E05B9A02A11B1A926987C5E30B33C6635.B6629E2B1BE573D872D396E5A4650302581DBCD0";
    },
        {
        downloadURL = "https://r15---sn-bvvbax-2iml.googlevideo.com/videoplayback?upn=rfqS32ShGLo&fexp=9416126%2C9420452%2C9422596%2C9423662%2C9424859&dur=323.964&expire=1450796829&sver=3&key=yt6&lmt=1429001118026615&mt=1450775129&mn=sn-bvvbax-2iml&mm=31&pl=16&id=o-AOCRM4CxluaEDjsUPa1mmbqbl55G-pDTx_M3zzY2EUBD&mime=video%2F3gpp&sparams=dur%2Cid%2Cip%2Cipbits%2Citag%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cnh%2Cpl%2Crequiressl%2Csource%2Cupn%2Cexpire&ipbits=0&requiressl=yes&ip=98.165.123.35&mv=m&itag=36&source=youtube&ms=au&nh=EAI&signature=6A7C67BB791D07FD41D61C920CC4755A636EDDFF.CF902749DB3DC63AA77563F72AFE30B5CA83F7D3&title=Lil+Wayne+-+She+Will+ft.+Drake%20%5B(null)p%5D";
        "fallback_host" = "tc.v4.cache1.googlevideo.com";
        itag = 36;
        quality = small;
        s = "1A7DA7C67BB79DD07FD41D61C920CC4755A636E6DFF.CF902749DB3DC63AA77563F72AFE30B5CA83F3D73D7";
        title = "Lil Wayne - She Will ft. Drake";
        type = "video/3gpp; codecs=mp4v.20.3, mp4a.40.2";
        url = "https://r15---sn-bvvbax-2iml.googlevideo.com/videoplayback?upn=rfqS32ShGLo&fexp=9416126%2C9420452%2C9422596%2C9423662%2C9424859&dur=323.964&expire=1450796829&sver=3&key=yt6&lmt=1429001118026615&mt=1450775129&mn=sn-bvvbax-2iml&mm=31&pl=16&id=o-AOCRM4CxluaEDjsUPa1mmbqbl55G-pDTx_M3zzY2EUBD&mime=video%2F3gpp&sparams=dur%2Cid%2Cip%2Cipbits%2Citag%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cnh%2Cpl%2Crequiressl%2Csource%2Cupn%2Cexpire&ipbits=0&requiressl=yes&ip=98.165.123.35&mv=m&itag=36&source=youtube&ms=au&nh=EAI&signature=6A7C67BB791D07FD41D61C920CC4755A636EDDFF.CF902749DB3DC63AA77563F72AFE30B5CA83F7D3";
    },
        {
        downloadURL = "https://r15---sn-bvvbax-2iml.googlevideo.com/videoplayback?upn=rfqS32ShGLo&fexp=9416126%2C9420452%2C9422596%2C9423662%2C9424859&dur=323.964&expire=1450796829&sver=3&key=yt6&lmt=1394255352494745&mt=1450775129&mn=sn-bvvbax-2iml&mm=31&pl=16&id=o-AOCRM4CxluaEDjsUPa1mmbqbl55G-pDTx_M3zzY2EUBD&mime=video%2F3gpp&sparams=dur%2Cid%2Cip%2Cipbits%2Citag%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cnh%2Cpl%2Crequiressl%2Csource%2Cupn%2Cexpire&ipbits=0&requiressl=yes&ip=98.165.123.35&mv=m&itag=17&source=youtube&ms=au&nh=EAI&signature=17625F69AC34E7F5DB400984ABBA7C8AACC101AC.6AD14EFD012791367720FBBB470FA95F2197BC4B&title=Lil+Wayne+-+She+Will+ft.+Drake%20%5B350p%5D";
        "fallback_host" = "tc.v7.cache6.googlevideo.com";
        format = "350p 3GP";
        height = 350;
        itag = 17;
        quality = small;
        s = "37607625F69AC04E7F5DB400984ABBA7C8AACC111AC.6AD14EFD012791367720FBBB470FA95F2197BB4CB4C";
        title = "Lil Wayne - She Will ft. Drake";
        type = "video/3gpp; codecs=mp4v.20.3, mp4a.40.2";
        url = "https://r15---sn-bvvbax-2iml.googlevideo.com/videoplayback?upn=rfqS32ShGLo&fexp=9416126%2C9420452%2C9422596%2C9423662%2C9424859&dur=323.964&expire=1450796829&sver=3&key=yt6&lmt=1394255352494745&mt=1450775129&mn=sn-bvvbax-2iml&mm=31&pl=16&id=o-AOCRM4CxluaEDjsUPa1mmbqbl55G-pDTx_M3zzY2EUBD&mime=video%2F3gpp&sparams=dur%2Cid%2Cip%2Cipbits%2Citag%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cnh%2Cpl%2Crequiressl%2Csource%2Cupn%2Cexpire&ipbits=0&requiressl=yes&ip=98.165.123.35&mv=m&itag=17&source=youtube&ms=au&nh=EAI&signature=17625F69AC34E7F5DB400984ABBA7C8AACC101AC.6AD14EFD012791367720FBBB470FA95F2197BC4B";
    }
)


    

The links are immediately downloadable. If &title parameter is removed from URL the video will playback natively rather than download.
Heavily based on various clicktoplugin javascript code.

Could easily be incorporated into an iOS app KBYourTube.h/m are the only files needed.
