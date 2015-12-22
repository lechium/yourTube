# yourTube
native objective-c wrapper for youtube get_video_info

Instantiate KBYourTube and get video streams in 2 lines of code;

    KBYourTube *tube = [[KBYourTube alloc] init];
    NSArray *streamArray = [tube getVideoStreamsForID:@"_7nYuyfkjCk"];
    
Would yield
    
    2015-12-21 20:29:55.121 yourTube[94810:15703223] streamArray: (
        {
        "fallback_host" = "tc.v20.cache6.googlevideo.com";
        format = "720p MP4";
        itag = 22;
        quality = hd720;
        s = "771171A2777DE13D6CE5320C210DCCA29F018FC6DBA.A7630D3C26F2F70EEFEB25889E1A1B8805EC0616616";
        title = "Lil+Wayne+-+She+Will+ft.+Drake";
        type = "video%2Fmp4%3B+codecs%3D%22avc1.64001F%2C+mp4a.40.2%22";
        url = "https://r15---sn-bvvbax-2iml.googlevideo.com/videoplayback?nh=EAI&fexp=9416126%2C9420452%2C9422596%2C9423662%2C9424859&ipbits=0&mime=video%2Fmp4&ratebypass=yes&itag=22&upn=8XDeh70fkMI&expire=1450776595&mt=1450754946&sparams=dur%2Cid%2Cip%2Cipbits%2Citag%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cnh%2Cpl%2Cratebypass%2Crequiressl%2Csource%2Cupn%2Cexpire&key=yt6&id=o-AF5K6y8liVQ1S9iLjUHOcIBdnb4a8g-rgcFwGc0wuidq&mn=sn-bvvbax-2iml&mm=31&ms=au&mv=m&source=youtube&pl=16&dur=323.895&lmt=1417236324599143&ip=98.165.123.35&requiressl=yes&sver=3&signature=671A2777DE73D6CE5320C210DCCA29F018FC1DBA.A7630D3C26F2F70EEFEB25889E1A1B8805EC0616&title=Lil+Wayne+-+She+Will+ft.+Drake";
    },
        {
        "fallback_host" = "tc.v6.cache3.googlevideo.com";
        format = "360p WebM";
        itag = 43;
        quality = medium;
        s = "A66F66990C6B3FC7CBEC424659EE753FC83FB5E4B59.63EBFC3F42B7C4879913E2DBAAE770CBB03845F75F7";
        title = "Lil+Wayne+-+She+Will+ft.+Drake";
        type = "video%2Fwebm%3B+codecs%3D%22vp8.0%2C+vorbis%22";
        url = "https://r15---sn-bvvbax-2iml.googlevideo.com/videoplayback?nh=EAI&fexp=9416126%2C9420452%2C9422596%2C9423662%2C9424859&ipbits=0&mime=video%2Fwebm&ratebypass=yes&itag=43&upn=8XDeh70fkMI&expire=1450776595&mt=1450754946&sparams=dur%2Cid%2Cip%2Cipbits%2Citag%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cnh%2Cpl%2Cratebypass%2Crequiressl%2Csource%2Cupn%2Cexpire&key=yt6&id=o-AF5K6y8liVQ1S9iLjUHOcIBdnb4a8g-rgcFwGc0wuidq&mn=sn-bvvbax-2iml&mm=31&ms=au&mv=m&source=youtube&pl=16&dur=0.000&lmt=1314629037323189&ip=98.165.123.35&requiressl=yes&sver=3&signature=466990C6B3AC7CBEC424659EE753FC83FB5EFB59.63EBFC3F42B7C4879913E2DBAAE770CBB03847F5&title=Lil+Wayne+-+She+Will+ft.+Drake";
    },
        {
        "fallback_host" = "tc.v2.cache7.googlevideo.com";
        format = "360p MP4";
        itag = 18;
        quality = medium;
        s = "F28128D4A27411AD2F11B479C93C468E2AFF9FF6CB3.8D060CD1A70913109C08CFFF60CACBA9C1A42BAEBAE";
        title = "Lil+Wayne+-+She+Will+ft.+Drake";
        type = "video%2Fmp4%3B+codecs%3D%22avc1.42001E%2C+mp4a.40.2%22";
        url = "https://r15---sn-bvvbax-2iml.googlevideo.com/videoplayback?nh=EAI&fexp=9416126%2C9420452%2C9422596%2C9423662%2C9424859&ipbits=0&mime=video%2Fmp4&ratebypass=yes&itag=18&upn=8XDeh70fkMI&expire=1450776595&mt=1450754946&sparams=dur%2Cid%2Cip%2Cipbits%2Citag%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cnh%2Cpl%2Cratebypass%2Crequiressl%2Csource%2Cupn%2Cexpire&key=yt6&id=o-AF5K6y8liVQ1S9iLjUHOcIBdnb4a8g-rgcFwGc0wuidq&mn=sn-bvvbax-2iml&mm=31&ms=au&mv=m&source=youtube&pl=16&dur=323.895&lmt=1417236323829380&ip=98.165.123.35&requiressl=yes&sver=3&signature=628D4A2741FAD2F11B479C93C468E2AFF9FF1CB3.8D060CD1A70913109C08CFFF60CACBA9C1A42EAB&title=Lil+Wayne+-+She+Will+ft.+Drake";
    },
        {
        "fallback_host" = "tc.v5.cache6.googlevideo.com";
        format = "240p FLV";
        itag = 5;
        quality = small;
        s = "5DD0DD7892C6D06C1754A2708FD7F74EA876B163FA6.9E138F2361723287B9125AFC4DE114950BC590CB0CB";
        title = "Lil+Wayne+-+She+Will+ft.+Drake";
        type = "video%2Fx-flv";
        url = "https://r15---sn-bvvbax-2iml.googlevideo.com/videoplayback?nh=EAI&id=o-AF5K6y8liVQ1S9iLjUHOcIBdnb4a8g-rgcFwGc0wuidq&fexp=9416126%2C9420452%2C9422596%2C9423662%2C9424859&ipbits=0&mime=video%2Fx-flv&mm=31&mn=sn-bvvbax-2iml&ms=au&mv=m&source=youtube&pl=16&itag=5&dur=323.866&lmt=1394255591390341&ip=98.165.123.35&upn=8XDeh70fkMI&expire=1450776595&mt=1450754946&requiressl=yes&sparams=dur%2Cid%2Cip%2Cipbits%2Citag%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cnh%2Cpl%2Crequiressl%2Csource%2Cupn%2Cexpire&sver=3&key=yt6&signature=3DD7892C6D56C1754A2708FD7F74EA876B160FA6.9E138F2361723287B9125AFC4DE114950BC59BC0&title=Lil+Wayne+-+She+Will+ft.+Drake";
    },
        {
        "fallback_host" = "tc.v4.cache1.googlevideo.com";
        itag = 36;
        quality = small;
        s = "76B96B74DA88B9B6DDCAA83A7E5B55E075715B99716.20E4304A25292D280DA3F915AFC2DB11F3E0A3C93C9";
        title = "Lil+Wayne+-+She+Will+ft.+Drake";
        type = "video%2F3gpp%3B+codecs%3D%22mp4v.20.3%2C+mp4a.40.2%22";
        url = "https://r15---sn-bvvbax-2iml.googlevideo.com/videoplayback?nh=EAI&id=o-AF5K6y8liVQ1S9iLjUHOcIBdnb4a8g-rgcFwGc0wuidq&fexp=9416126%2C9420452%2C9422596%2C9423662%2C9424859&ipbits=0&mime=video%2F3gpp&mm=31&mn=sn-bvvbax-2iml&ms=au&mv=m&source=youtube&pl=16&itag=36&dur=323.964&lmt=1429001118026615&ip=98.165.123.35&upn=8XDeh70fkMI&expire=1450776595&mt=1450754946&requiressl=yes&sparams=dur%2Cid%2Cip%2Cipbits%2Citag%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cnh%2Cpl%2Crequiressl%2Csource%2Cupn%2Cexpire&sver=3&key=yt6&signature=96B74DA88B7B6DDCAA83A7E5B55E075715B99716.20E4304A25292D280DA3F915AFC2DB11F3E0A9C3&title=Lil+Wayne+-+She+Will+ft.+Drake";
    },
        {
        "fallback_host" = "tc.v7.cache6.googlevideo.com";
        format = "350p 3GP";
        itag = 17;
        quality = small;
        s = "00F80F7E9C57080433C4FC099AD2E69FDA97B825F78.D0498F64BC1070FA2072A055E6AEC74260375BAABAA";
        title = "Lil+Wayne+-+She+Will+ft.+Drake";
        type = "video%2F3gpp%3B+codecs%3D%22mp4v.20.3%2C+mp4a.40.2%22";
        url = "https://r15---sn-bvvbax-2iml.googlevideo.com/videoplayback?nh=EAI&id=o-AF5K6y8liVQ1S9iLjUHOcIBdnb4a8g-rgcFwGc0wuidq&fexp=9416126%2C9420452%2C9422596%2C9423662%2C9424859&ipbits=0&mime=video%2F3gpp&mm=31&mn=sn-bvvbax-2iml&ms=au&mv=m&source=youtube&pl=16&itag=17&dur=323.964&lmt=1394255352494745&ip=98.165.123.35&upn=8XDeh70fkMI&expire=1450776595&mt=1450754946&requiressl=yes&sparams=dur%2Cid%2Cip%2Cipbits%2Citag%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cnh%2Cpl%2Crequiressl%2Csource%2Cupn%2Cexpire&sver=3&key=yt6&signature=50F7E9C57000433C4FC099AD2E69FDA97B828F78.D0498F64BC1070FA2072A055E6AEC74260375AAB&title=Lil+Wayne+-+She+Will+ft.+Drake";
    }
)

    

The links are immediately downloadable. If &title parameter is removed from URL the video will playback natively rather than download.
Heavily based on various clicktoplugin javascript code.

Could easily be incorporated into an iOS app KBYourTube.h/m are the only files needed.
