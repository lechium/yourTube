# yourTube
native objective-c wrapper for youtube get_video_info

Use the KBYourTube singleton with the following method to get video details.

    [[KBYourTube sharedInstance] getVideoDetailsForID:@"_7nYuyfkjCk" completionBlock:^(NSDictionary *videoDetails) {
    
        NSLog(@"got details successfully: %@", videoDetails);
    
    } failureBlock:^(NSString *error) {

        NSLog(@"fail!: %@", error);

    }];
    
Would yield
    
    2015-12-22 11:43:10.334 yourTube[31692:15977316] got details successfully: {
    author = fullaswag;
    duration = 324;
    imageURLHQ = "https://i.ytimg.com/vi/_7nYuyfkjCk/hqdefault.jpg";
    imageURLMQ = "https://i.ytimg.com/vi/_7nYuyfkjCk/mqdefault.jpg";
    imageURLSD = "https://i.ytimg.com/vi/_7nYuyfkjCk/sddefault.jpg";
    keywords = "wayne,she,loves,drake,said,will,young,money,lil,awesome,2011,feat,wants,everybody,cool,got,funny,remix";
    streams =     (
                {
            downloadURL = "https://r15---sn-bvvbax-2iml.googlevideo.com/videoplayback?id=o-AB7GZHHiHkDiy5eNTdlV7RyBNOhIXII7Q1s9fseAS7Dg&mm=31&mn=sn-bvvbax-2iml&ms=au&mt=1450809611&sparams=dur%2Cid%2Cip%2Cipbits%2Citag%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cnh%2Cpl%2Cratebypass%2Crequiressl%2Csource%2Cupn%2Cexpire&mv=m&ip=xx&itag=22&pl=16&upn=JdAuDmzI3O0&source=youtube&expire=1450831390&sver=3&ipbits=0&dur=323.895&lmt=1417236324599143&ratebypass=yes&fexp=9416126%2C9420452%2C9422596%2C9423662%2C9424859&mime=video%2Fmp4&key=yt6&nh=EAI&requiressl=yes&signature=AE85B58B0583550660BD3673D7F69FA5179E70A4.BC283EDCED45E373D01E3F2CB2A884B8F193470B&title=Lil Wayne - She Will ft. Drake%20%5B720p%5D";
            "fallback_host" = "tc.v20.cache6.googlevideo.com";
            format = "720p MP4";
            height = 720;
            itag = 22;
            quality = hd720;
            s = "8E87E85B58B0573550660BD3673D7F69FA5179EA0A4.BC283EDCED45E373D01E3F2CB2A884B8F1934B07B07";
            title = "Lil Wayne - She Will ft. Drake";
            type = "video/mp4; codecs=avc1.64001F, mp4a.40.2";
            url = "https://r15---sn-bvvbax-2iml.googlevideo.com/videoplayback?id=o-AB7GZHHiHkDiy5eNTdlV7RyBNOhIXII7Q1s9fseAS7Dg&mm=31&mn=sn-bvvbax-2iml&ms=au&mt=1450809611&sparams=dur%2Cid%2Cip%2Cipbits%2Citag%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cnh%2Cpl%2Cratebypass%2Crequiressl%2Csource%2Cupn%2Cexpire&mv=m&ip=xx&itag=22&pl=16&upn=JdAuDmzI3O0&source=youtube&expire=1450831390&sver=3&ipbits=0&dur=323.895&lmt=1417236324599143&ratebypass=yes&fexp=9416126%2C9420452%2C9422596%2C9423662%2C9424859&mime=video%2Fmp4&key=yt6&nh=EAI&requiressl=yes&signature=AE85B58B0583550660BD3673D7F69FA5179E70A4.BC283EDCED45E373D01E3F2CB2A884B8F193470B";
        },
                {
            downloadURL = "https://r15---sn-bvvbax-2iml.googlevideo.com/videoplayback?id=o-AB7GZHHiHkDiy5eNTdlV7RyBNOhIXII7Q1s9fseAS7Dg&mm=31&mn=sn-bvvbax-2iml&ms=au&mt=1450809611&sparams=dur%2Cid%2Cip%2Cipbits%2Citag%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cnh%2Cpl%2Cratebypass%2Crequiressl%2Csource%2Cupn%2Cexpire&mv=m&ip=xx&itag=43&pl=16&upn=JdAuDmzI3O0&source=youtube&expire=1450831390&sver=3&ipbits=0&dur=0.000&lmt=1314629037323189&ratebypass=yes&fexp=9416126%2C9420452%2C9422596%2C9423662%2C9424859&mime=video%2Fwebm&key=yt6&nh=EAI&requiressl=yes&signature=1057A1D647B56224754900F0F9251D575273E787.1988569E3EE34F567790DC502EA163FB8BE01E35&title=Lil Wayne - She Will ft. Drake%20%5B360p%5D";
            "fallback_host" = "tc.v6.cache3.googlevideo.com";
            format = "360p WebM";
            height = 360;
            itag = 43;
            quality = medium;
            s = "B05E057A1D647E56224754900F0F9251D5752731787.1988569E3EE34F567790DC502EA163FB8BE0153E53E";
            title = "Lil Wayne - She Will ft. Drake";
            type = "video/webm; codecs=vp8.0, vorbis";
            url = "https://r15---sn-bvvbax-2iml.googlevideo.com/videoplayback?id=o-AB7GZHHiHkDiy5eNTdlV7RyBNOhIXII7Q1s9fseAS7Dg&mm=31&mn=sn-bvvbax-2iml&ms=au&mt=1450809611&sparams=dur%2Cid%2Cip%2Cipbits%2Citag%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cnh%2Cpl%2Cratebypass%2Crequiressl%2Csource%2Cupn%2Cexpire&mv=m&ip=xx&itag=43&pl=16&upn=JdAuDmzI3O0&source=youtube&expire=1450831390&sver=3&ipbits=0&dur=0.000&lmt=1314629037323189&ratebypass=yes&fexp=9416126%2C9420452%2C9422596%2C9423662%2C9424859&mime=video%2Fwebm&key=yt6&nh=EAI&requiressl=yes&signature=1057A1D647B56224754900F0F9251D575273E787.1988569E3EE34F567790DC502EA163FB8BE01E35";
        },
                {
            downloadURL = "https://r15---sn-bvvbax-2iml.googlevideo.com/videoplayback?id=o-AB7GZHHiHkDiy5eNTdlV7RyBNOhIXII7Q1s9fseAS7Dg&mm=31&mn=sn-bvvbax-2iml&ms=au&mt=1450809611&sparams=dur%2Cid%2Cip%2Cipbits%2Citag%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cnh%2Cpl%2Cratebypass%2Crequiressl%2Csource%2Cupn%2Cexpire&mv=m&ip=xx&itag=18&pl=16&upn=JdAuDmzI3O0&source=youtube&expire=1450831390&sver=3&ipbits=0&dur=323.895&lmt=1417236323829380&ratebypass=yes&fexp=9416126%2C9420452%2C9422596%2C9423662%2C9424859&mime=video%2Fmp4&key=yt6&nh=EAI&requiressl=yes&signature=050DD05EB426F4937D2BFE512D7B2BCBF2C2D2A9.ADEDA3033A803ED8F7D3297CA89773B09169AAF8&title=Lil Wayne - She Will ft. Drake%20%5B360p%5D";
            "fallback_host" = "tc.v2.cache7.googlevideo.com";
            format = "360p MP4";
            height = 360;
            itag = 18;
            quality = medium;
            s = "250D50DD05EB4D6F4937D2BFE512D7B2BCBF2C202A9.ADEDA3033A803ED8F7D3297CA89773B09169A8FA8FA";
            title = "Lil Wayne - She Will ft. Drake";
            type = "video/mp4; codecs=avc1.42001E, mp4a.40.2";
            url = "https://r15---sn-bvvbax-2iml.googlevideo.com/videoplayback?id=o-AB7GZHHiHkDiy5eNTdlV7RyBNOhIXII7Q1s9fseAS7Dg&mm=31&mn=sn-bvvbax-2iml&ms=au&mt=1450809611&sparams=dur%2Cid%2Cip%2Cipbits%2Citag%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cnh%2Cpl%2Cratebypass%2Crequiressl%2Csource%2Cupn%2Cexpire&mv=m&ip=xx&itag=18&pl=16&upn=JdAuDmzI3O0&source=youtube&expire=1450831390&sver=3&ipbits=0&dur=323.895&lmt=1417236323829380&ratebypass=yes&fexp=9416126%2C9420452%2C9422596%2C9423662%2C9424859&mime=video%2Fmp4&key=yt6&nh=EAI&requiressl=yes&signature=050DD05EB426F4937D2BFE512D7B2BCBF2C2D2A9.ADEDA3033A803ED8F7D3297CA89773B09169AAF8";
        },
                {
            downloadURL = "https://r15---sn-bvvbax-2iml.googlevideo.com/videoplayback?expire=1450831390&id=o-AB7GZHHiHkDiy5eNTdlV7RyBNOhIXII7Q1s9fseAS7Dg&sver=3&mm=31&ipbits=0&dur=323.866&mn=sn-bvvbax-2iml&ms=au&mt=1450809611&sparams=dur%2Cid%2Cip%2Cipbits%2Citag%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cnh%2Cpl%2Crequiressl%2Csource%2Cupn%2Cexpire&mv=m&lmt=1394255591390341&ip=xx&itag=5&fexp=9416126%2C9420452%2C9422596%2C9423662%2C9424859&pl=16&mime=video%2Fx-flv&key=yt6&nh=EAI&source=youtube&upn=JdAuDmzI3O0&requiressl=yes&signature=41BE0FB8273120B33F84C188F453BF532FBC2187.235896F5BFA3F23B426EA94A509E57E38FE36F16&title=Lil Wayne - She Will ft. Drake%20%5B240p%5D";
            "fallback_host" = "tc.v5.cache6.googlevideo.com";
            format = "240p FLV";
            height = 240;
            itag = 5;
            quality = small;
            s = "31B21BE0FB8272120B33F84C188F453BF532FBC4187.235896F5BFA3F23B426EA94A509E57E38FE3661F61F";
            title = "Lil Wayne - She Will ft. Drake";
            type = "video/x-flv";
            url = "https://r15---sn-bvvbax-2iml.googlevideo.com/videoplayback?expire=1450831390&id=o-AB7GZHHiHkDiy5eNTdlV7RyBNOhIXII7Q1s9fseAS7Dg&sver=3&mm=31&ipbits=0&dur=323.866&mn=sn-bvvbax-2iml&ms=au&mt=1450809611&sparams=dur%2Cid%2Cip%2Cipbits%2Citag%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cnh%2Cpl%2Crequiressl%2Csource%2Cupn%2Cexpire&mv=m&lmt=1394255591390341&ip=xx&itag=5&fexp=9416126%2C9420452%2C9422596%2C9423662%2C9424859&pl=16&mime=video%2Fx-flv&key=yt6&nh=EAI&source=youtube&upn=JdAuDmzI3O0&requiressl=yes&signature=41BE0FB8273120B33F84C188F453BF532FBC2187.235896F5BFA3F23B426EA94A509E57E38FE36F16";
        },
                {
            downloadURL = "https://r15---sn-bvvbax-2iml.googlevideo.com/videoplayback?expire=1450831390&id=o-AB7GZHHiHkDiy5eNTdlV7RyBNOhIXII7Q1s9fseAS7Dg&sver=3&mm=31&ipbits=0&dur=323.964&mn=sn-bvvbax-2iml&ms=au&mt=1450809611&sparams=dur%2Cid%2Cip%2Cipbits%2Citag%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cnh%2Cpl%2Crequiressl%2Csource%2Cupn%2Cexpire&mv=m&lmt=1429001118026615&ip=xx&itag=36&fexp=9416126%2C9420452%2C9422596%2C9423662%2C9424859&pl=16&mime=video%2F3gpp&key=yt6&nh=EAI&source=youtube&upn=JdAuDmzI3O0&requiressl=yes&signature=C42B6ABA04D44C32B957606686149B017C18D6F0.CC4BCE600E63D8863EDC8D9D697EDAB2122F3EF7&title=Lil Wayne - She Will ft. Drake%20%5B(null)p%5D";
            "fallback_host" = "tc.v4.cache1.googlevideo.com";
            itag = 36;
            quality = small;
            s = "D42D42B6ABA04D44C32B957606686149B017C18C6F0.CC4BCE600E63D8863EDC8D9D697EDAB2122F37FE7FE";
            title = "Lil Wayne - She Will ft. Drake";
            type = "video/3gpp; codecs=mp4v.20.3, mp4a.40.2";
            url = "https://r15---sn-bvvbax-2iml.googlevideo.com/videoplayback?expire=1450831390&id=o-AB7GZHHiHkDiy5eNTdlV7RyBNOhIXII7Q1s9fseAS7Dg&sver=3&mm=31&ipbits=0&dur=323.964&mn=sn-bvvbax-2iml&ms=au&mt=1450809611&sparams=dur%2Cid%2Cip%2Cipbits%2Citag%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cnh%2Cpl%2Crequiressl%2Csource%2Cupn%2Cexpire&mv=m&lmt=1429001118026615&ip=xx&itag=36&fexp=9416126%2C9420452%2C9422596%2C9423662%2C9424859&pl=16&mime=video%2F3gpp&key=yt6&nh=EAI&source=youtube&upn=JdAuDmzI3O0&requiressl=yes&signature=C42B6ABA04D44C32B957606686149B017C18D6F0.CC4BCE600E63D8863EDC8D9D697EDAB2122F3EF7";
        },
                {
            downloadURL = "https://r15---sn-bvvbax-2iml.googlevideo.com/videoplayback?expire=1450831390&id=o-AB7GZHHiHkDiy5eNTdlV7RyBNOhIXII7Q1s9fseAS7Dg&sver=3&mm=31&ipbits=0&dur=323.964&mn=sn-bvvbax-2iml&ms=au&mt=1450809611&sparams=dur%2Cid%2Cip%2Cipbits%2Citag%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cnh%2Cpl%2Crequiressl%2Csource%2Cupn%2Cexpire&mv=m&lmt=1394255352494745&ip=xx&itag=17&fexp=9416126%2C9420452%2C9422596%2C9423662%2C9424859&pl=16&mime=video%2F3gpp&key=yt6&nh=EAI&source=youtube&upn=JdAuDmzI3O0&requiressl=yes&signature=2DE32E5AAD1720B9AA4A752DFE0F229F459DC3F4.8E71B0CBE999ADAE79E2486C8DA26FBF6FCF1465&title=Lil Wayne - She Will ft. Drake%20%5B350p%5D";
            "fallback_host" = "tc.v7.cache6.googlevideo.com";
            format = "350p 3GP";
            height = 350;
            itag = 17;
            quality = small;
            s = "1DECDE32E5AADC720B9AA4A752DFE0F229F459D23F4.8E71B0CBE999ADAE79E2486C8DA26FBF6FCF1564564";
            title = "Lil Wayne - She Will ft. Drake";
            type = "video/3gpp; codecs=mp4v.20.3, mp4a.40.2";
            url = "https://r15---sn-bvvbax-2iml.googlevideo.com/videoplayback?expire=1450831390&id=o-AB7GZHHiHkDiy5eNTdlV7RyBNOhIXII7Q1s9fseAS7Dg&sver=3&mm=31&ipbits=0&dur=323.964&mn=sn-bvvbax-2iml&ms=au&mt=1450809611&sparams=dur%2Cid%2Cip%2Cipbits%2Citag%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cnh%2Cpl%2Crequiressl%2Csource%2Cupn%2Cexpire&mv=m&lmt=1394255352494745&ip=xx&itag=17&fexp=9416126%2C9420452%2C9422596%2C9423662%2C9424859&pl=16&mime=video%2F3gpp&key=yt6&nh=EAI&source=youtube&upn=JdAuDmzI3O0&requiressl=yes&signature=2DE32E5AAD1720B9AA4A752DFE0F229F459DC3F4.8E71B0CBE999ADAE79E2486C8DA26FBF6FCF1465";
        }
    );
    title = "Lil Wayne - She Will ft. Drake";
    videoID = "_7nYuyfkjCk";
    views = 22758434;
}


    

Heavily based on various clicktoplugin javascript code.

Could easily be incorporated into an iOS app KBYourTube.h/m are the only files needed.

