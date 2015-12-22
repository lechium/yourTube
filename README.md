# yourTube
native objective-c wrapper for youtube get_video_info

Instantiate KBYourTube and get video streams in 2 lines of code;

    KBYourTube *tube = [[KBYourTube alloc] init];
    NSArray *streamArray = [tube getVideoStreamsForID:@"_7nYuyfkjCk"];
    
Would yield
    
    2015-12-22 01:56:40.325 yourTube[8664:15826816] streamArray: (
        {
        downloadURL = "https://r15---sn-bvvbax-2iml.googlevideo.com/videoplayback?dur=323.895&mime=video%2Fmp4&itag=22&upn=QM3uRh_kIrc&nh=EAI&ipbits=0&sver=3&fexp=9416126%2C9420452%2C9422596%2C9423662%2C9424859&key=yt6&expire=1450796200&lmt=1417236324599143&sparams=dur%2Cid%2Cip%2Cipbits%2Citag%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cnh%2Cpl%2Cratebypass%2Crequiressl%2Csource%2Cupn%2Cexpire&mm=31&source=youtube&mn=sn-bvvbax-2iml&ratebypass=yes&ip=98.165.123.35&requiressl=yes&id=o-ACqRGudfksKBRgVOPDN0YT6vCYyCwFe98QQRq-k_WlM6&ms=au&mt=1450774465&pl=16&mv=m&signature=62668BC0C8AE0CBDBD733898DFF57E5A0B476FB7.55D405B8EBB5BBE51BDCAE7C03947548F60B427E&title=Lil+Wayne+-+She+Will+ft.+Drake%20%5B720p%5D";
        "fallback_host" = "tc.v20.cache6.googlevideo.com";
        format = "720p MP4";
        height = 720;
        itag = 22;
        quality = hd720;
        s = "A2662668BC0C86E0CBDBD733898DFF57E5A0B476FB7.55D405B8EBB5BBE51BDCAE7C03947548F60B4E72E72";
        title = "Lil Wayne - She Will ft. Drake";
        type = "video/mp4; codecs=avc1.64001F, mp4a.40.2";
        url = "https%3A%2F%2Fr15---sn-bvvbax-2iml.googlevideo.com%2Fvideoplayback%3Fdur%3D323.895%26mime%3Dvideo%252Fmp4%26itag%3D22%26upn%3DQM3uRh_kIrc%26nh%3DEAI%26ipbits%3D0%26sver%3D3%26fexp%3D9416126%252C9420452%252C9422596%252C9423662%252C9424859%26key%3Dyt6%26expire%3D1450796200%26lmt%3D1417236324599143%26sparams%3Ddur%252Cid%252Cip%252Cipbits%252Citag%252Clmt%252Cmime%252Cmm%252Cmn%252Cms%252Cmv%252Cnh%252Cpl%252Cratebypass%252Crequiressl%252Csource%252Cupn%252Cexpire%26mm%3D31%26source%3Dyoutube%26mn%3Dsn-bvvbax-2iml%26ratebypass%3Dyes%26ip%3D98.165.123.35%26requiressl%3Dyes%26id%3Do-ACqRGudfksKBRgVOPDN0YT6vCYyCwFe98QQRq-k_WlM6%26ms%3Dau%26mt%3D1450774465%26pl%3D16%26mv%3Dm";
    },
        {
        downloadURL = "https://r15---sn-bvvbax-2iml.googlevideo.com/videoplayback?dur=0.000&mime=video%2Fwebm&itag=43&upn=QM3uRh_kIrc&nh=EAI&ipbits=0&sver=3&fexp=9416126%2C9420452%2C9422596%2C9423662%2C9424859&key=yt6&expire=1450796200&lmt=1314629037323189&sparams=dur%2Cid%2Cip%2Cipbits%2Citag%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cnh%2Cpl%2Cratebypass%2Crequiressl%2Csource%2Cupn%2Cexpire&mm=31&source=youtube&mn=sn-bvvbax-2iml&ratebypass=yes&ip=98.165.123.35&requiressl=yes&id=o-ACqRGudfksKBRgVOPDN0YT6vCYyCwFe98QQRq-k_WlM6&ms=au&mt=1450774465&pl=16&mv=m&signature=E0DB0E86083C3F3D8D41E6AD7E4C67F2F3735C01.C3D2F98EB2BB4027CDB10B2FEFC6DA407A0B4910&title=Lil+Wayne+-+She+Will+ft.+Drake%20%5B360p%5D";
        "fallback_host" = "tc.v6.cache3.googlevideo.com";
        format = "360p WebM";
        height = 360;
        itag = 43;
        quality = medium;
        s = "30D50DB0E86085C3F3D8D41E6AD7E4C67F2F373EC01.C3D2F98EB2BB4027CDB10B2FEFC6DA407A0B4019019";
        title = "Lil Wayne - She Will ft. Drake";
        type = "video/webm; codecs=vp8.0, vorbis";
        url = "https%3A%2F%2Fr15---sn-bvvbax-2iml.googlevideo.com%2Fvideoplayback%3Fdur%3D0.000%26mime%3Dvideo%252Fwebm%26itag%3D43%26upn%3DQM3uRh_kIrc%26nh%3DEAI%26ipbits%3D0%26sver%3D3%26fexp%3D9416126%252C9420452%252C9422596%252C9423662%252C9424859%26key%3Dyt6%26expire%3D1450796200%26lmt%3D1314629037323189%26sparams%3Ddur%252Cid%252Cip%252Cipbits%252Citag%252Clmt%252Cmime%252Cmm%252Cmn%252Cms%252Cmv%252Cnh%252Cpl%252Cratebypass%252Crequiressl%252Csource%252Cupn%252Cexpire%26mm%3D31%26source%3Dyoutube%26mn%3Dsn-bvvbax-2iml%26ratebypass%3Dyes%26ip%3D98.165.123.35%26requiressl%3Dyes%26id%3Do-ACqRGudfksKBRgVOPDN0YT6vCYyCwFe98QQRq-k_WlM6%26ms%3Dau%26mt%3D1450774465%26pl%3D16%26mv%3Dm";
    },
        {
        downloadURL = "https://r15---sn-bvvbax-2iml.googlevideo.com/videoplayback?dur=323.895&mime=video%2Fmp4&itag=18&upn=QM3uRh_kIrc&nh=EAI&ipbits=0&sver=3&fexp=9416126%2C9420452%2C9422596%2C9423662%2C9424859&key=yt6&expire=1450796200&lmt=1417236323829380&sparams=dur%2Cid%2Cip%2Cipbits%2Citag%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cnh%2Cpl%2Cratebypass%2Crequiressl%2Csource%2Cupn%2Cexpire&mm=31&source=youtube&mn=sn-bvvbax-2iml&ratebypass=yes&ip=98.165.123.35&requiressl=yes&id=o-ACqRGudfksKBRgVOPDN0YT6vCYyCwFe98QQRq-k_WlM6&ms=au&mt=1450774465&pl=16&mv=m&signature=3629950A0A7FF8FC714720EAB0B198C78DFE1AC4.A4ACE4D05FE8671C4A108E24CF7042EB88777FCD&title=Lil+Wayne+-+She+Will+ft.+Drake%20%5B360p%5D";
        "fallback_host" = "tc.v2.cache7.googlevideo.com";
        format = "360p MP4";
        height = 360;
        itag = 18;
        quality = medium;
        s = "7621629950A0A1FF8FC714720EAB0B198C78DFE3AC4.A4ACE4D05FE8671C4A108E24CF7042EB88777DCFDCF";
        title = "Lil Wayne - She Will ft. Drake";
        type = "video/mp4; codecs=avc1.42001E, mp4a.40.2";
        url = "https%3A%2F%2Fr15---sn-bvvbax-2iml.googlevideo.com%2Fvideoplayback%3Fdur%3D323.895%26mime%3Dvideo%252Fmp4%26itag%3D18%26upn%3DQM3uRh_kIrc%26nh%3DEAI%26ipbits%3D0%26sver%3D3%26fexp%3D9416126%252C9420452%252C9422596%252C9423662%252C9424859%26key%3Dyt6%26expire%3D1450796200%26lmt%3D1417236323829380%26sparams%3Ddur%252Cid%252Cip%252Cipbits%252Citag%252Clmt%252Cmime%252Cmm%252Cmn%252Cms%252Cmv%252Cnh%252Cpl%252Cratebypass%252Crequiressl%252Csource%252Cupn%252Cexpire%26mm%3D31%26source%3Dyoutube%26mn%3Dsn-bvvbax-2iml%26ratebypass%3Dyes%26ip%3D98.165.123.35%26requiressl%3Dyes%26id%3Do-ACqRGudfksKBRgVOPDN0YT6vCYyCwFe98QQRq-k_WlM6%26ms%3Dau%26mt%3D1450774465%26pl%3D16%26mv%3Dm";
    },
        {
        downloadURL = "https://r15---sn-bvvbax-2iml.googlevideo.com/videoplayback?dur=323.866&key=yt6&mime=video%2Fx-flv&expire=1450796200&lmt=1394255591390341&itag=5&nh=EAI&upn=QM3uRh_kIrc&sparams=dur%2Cid%2Cip%2Cipbits%2Citag%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cnh%2Cpl%2Crequiressl%2Csource%2Cupn%2Cexpire&mm=31&source=youtube&mn=sn-bvvbax-2iml&ipbits=0&ip=98.165.123.35&sver=3&requiressl=yes&id=o-ACqRGudfksKBRgVOPDN0YT6vCYyCwFe98QQRq-k_WlM6&ms=au&fexp=9416126%2C9420452%2C9422596%2C9423662%2C9424859&mt=1450774465&pl=16&mv=m&signature=538FE3BF23B3D506496ED3B424E29921A46F937A.541591013E76D1C70924651E2C8C414D9811AFA6&title=Lil+Wayne+-+She+Will+ft.+Drake%20%5B240p%5D";
        "fallback_host" = "tc.v5.cache6.googlevideo.com";
        format = "240p FLV";
        height = 240;
        itag = 5;
        quality = small;
        s = "B38938FE3BF2393D506496ED3B424E29921A46F537A.541591013E76D1C70924651E2C8C414D9811A6AF6AF";
        title = "Lil Wayne - She Will ft. Drake";
        type = "video/x-flv";
        url = "https%3A%2F%2Fr15---sn-bvvbax-2iml.googlevideo.com%2Fvideoplayback%3Fdur%3D323.866%26key%3Dyt6%26mime%3Dvideo%252Fx-flv%26expire%3D1450796200%26lmt%3D1394255591390341%26itag%3D5%26nh%3DEAI%26upn%3DQM3uRh_kIrc%26sparams%3Ddur%252Cid%252Cip%252Cipbits%252Citag%252Clmt%252Cmime%252Cmm%252Cmn%252Cms%252Cmv%252Cnh%252Cpl%252Crequiressl%252Csource%252Cupn%252Cexpire%26mm%3D31%26source%3Dyoutube%26mn%3Dsn-bvvbax-2iml%26ipbits%3D0%26ip%3D98.165.123.35%26sver%3D3%26requiressl%3Dyes%26id%3Do-ACqRGudfksKBRgVOPDN0YT6vCYyCwFe98QQRq-k_WlM6%26ms%3Dau%26fexp%3D9416126%252C9420452%252C9422596%252C9423662%252C9424859%26mt%3D1450774465%26pl%3D16%26mv%3Dm";
    },
        {
        downloadURL = "https://r15---sn-bvvbax-2iml.googlevideo.com/videoplayback?dur=323.964&key=yt6&mime=video%2F3gpp&expire=1450796200&lmt=1429001118026615&itag=36&nh=EAI&upn=QM3uRh_kIrc&sparams=dur%2Cid%2Cip%2Cipbits%2Citag%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cnh%2Cpl%2Crequiressl%2Csource%2Cupn%2Cexpire&mm=31&source=youtube&mn=sn-bvvbax-2iml&ipbits=0&ip=98.165.123.35&sver=3&requiressl=yes&id=o-ACqRGudfksKBRgVOPDN0YT6vCYyCwFe98QQRq-k_WlM6&ms=au&fexp=9416126%2C9420452%2C9422596%2C9423662%2C9424859&mt=1450774465&pl=16&mv=m&signature=AAA7CE46CB1DA35FBB9CDD629A435EAF5F9659A2.4E510EC2D48CF1B43E3B71E952043C919F8ED57C&title=Lil+Wayne+-+She+Will+ft.+Drake%20%5B(null)p%5D";
        "fallback_host" = "tc.v4.cache1.googlevideo.com";
        itag = 36;
        quality = small;
        s = "1AA5AA7CE46CB5DA35FBB9CDD629A435EAF5F96A9A2.4E510EC2D48CF1B43E3B71E952043C919F8EDC75C75";
        title = "Lil Wayne - She Will ft. Drake";
        type = "video/3gpp; codecs=mp4v.20.3, mp4a.40.2";
        url = "https%3A%2F%2Fr15---sn-bvvbax-2iml.googlevideo.com%2Fvideoplayback%3Fdur%3D323.964%26key%3Dyt6%26mime%3Dvideo%252F3gpp%26expire%3D1450796200%26lmt%3D1429001118026615%26itag%3D36%26nh%3DEAI%26upn%3DQM3uRh_kIrc%26sparams%3Ddur%252Cid%252Cip%252Cipbits%252Citag%252Clmt%252Cmime%252Cmm%252Cmn%252Cms%252Cmv%252Cnh%252Cpl%252Crequiressl%252Csource%252Cupn%252Cexpire%26mm%3D31%26source%3Dyoutube%26mn%3Dsn-bvvbax-2iml%26ipbits%3D0%26ip%3D98.165.123.35%26sver%3D3%26requiressl%3Dyes%26id%3Do-ACqRGudfksKBRgVOPDN0YT6vCYyCwFe98QQRq-k_WlM6%26ms%3Dau%26fexp%3D9416126%252C9420452%252C9422596%252C9423662%252C9424859%26mt%3D1450774465%26pl%3D16%26mv%3Dm";
    },
        {
        downloadURL = "https://r15---sn-bvvbax-2iml.googlevideo.com/videoplayback?dur=323.964&key=yt6&mime=video%2F3gpp&expire=1450796200&lmt=1394255352494745&itag=17&nh=EAI&upn=QM3uRh_kIrc&sparams=dur%2Cid%2Cip%2Cipbits%2Citag%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cnh%2Cpl%2Crequiressl%2Csource%2Cupn%2Cexpire&mm=31&source=youtube&mn=sn-bvvbax-2iml&ipbits=0&ip=98.165.123.35&sver=3&requiressl=yes&id=o-ACqRGudfksKBRgVOPDN0YT6vCYyCwFe98QQRq-k_WlM6&ms=au&fexp=9416126%2C9420452%2C9422596%2C9423662%2C9424859&mt=1450774465&pl=16&mv=m&signature=2F3EE13975B0E72938475F81C78F8B1DB4460C0E.20CD84D9A187236BA644FF4BC7DBA7FE53C4521F&title=Lil+Wayne+-+She+Will+ft.+Drake%20%5B350p%5D";
        "fallback_host" = "tc.v7.cache6.googlevideo.com";
        format = "350p 3GP";
        height = 350;
        itag = 17;
        quality = small;
        s = "BF30F3EE1397500E72938475F81C78F8B1DB4462C0E.20CD84D9A187236BA644FF4BC7DBA7FE53C45F12F12";
        title = "Lil Wayne - She Will ft. Drake";
        type = "video/3gpp; codecs=mp4v.20.3, mp4a.40.2";
        url = "https%3A%2F%2Fr15---sn-bvvbax-2iml.googlevideo.com%2Fvideoplayback%3Fdur%3D323.964%26key%3Dyt6%26mime%3Dvideo%252F3gpp%26expire%3D1450796200%26lmt%3D1394255352494745%26itag%3D17%26nh%3DEAI%26upn%3DQM3uRh_kIrc%26sparams%3Ddur%252Cid%252Cip%252Cipbits%252Citag%252Clmt%252Cmime%252Cmm%252Cmn%252Cms%252Cmv%252Cnh%252Cpl%252Crequiressl%252Csource%252Cupn%252Cexpire%26mm%3D31%26source%3Dyoutube%26mn%3Dsn-bvvbax-2iml%26ipbits%3D0%26ip%3D98.165.123.35%26sver%3D3%26requiressl%3Dyes%26id%3Do-ACqRGudfksKBRgVOPDN0YT6vCYyCwFe98QQRq-k_WlM6%26ms%3Dau%26fexp%3D9416126%252C9420452%252C9422596%252C9423662%252C9424859%26mt%3D1450774465%26pl%3D16%26mv%3Dm";
    }
)


    

The links are immediately downloadable. If &title parameter is removed from URL the video will playback natively rather than download.
Heavily based on various clicktoplugin javascript code.

Could easily be incorporated into an iOS app KBYourTube.h/m are the only files needed.
