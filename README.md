# yourTube
native objective-c wrapper for youtube get_video_info

Use the KBYourTube singleton with the following method to get video details.

    [[KBYourTube sharedInstance] getVideoDetailsForID:@"_7nYuyfkjCk" completionBlock:^(NSDictionary *videoDetails) {
    
        NSLog(@"got details successfully: %@", videoDetails);
    
    } failureBlock:^(NSString *error) {

        NSLog(@"fail!: %@", error);

    }];
    
Would yield
    
    2015-12-26 18:26:46.084 yourTube[53626:16977819] got details successfully: {
    author = fullaswag;
    duration = 324;
    images =     {
        high = "https://i.ytimg.com/vi/_7nYuyfkjCk/hqdefault.jpg";
        medium = "https://i.ytimg.com/vi/_7nYuyfkjCk/mqdefault.jpg";
        standard = "https://i.ytimg.com/vi/_7nYuyfkjCk/sddefault.jpg";
    };
    keywords = "wayne,she,loves,drake,said,will,young,money,lil,awesome,2011,feat,wants,everybody,cool,got,funny,remix";
    streams =     (
                {
            extension = mp4;
            "fallback_host" = "tc.v20.cache6.googlevideo.com";
            format = "720p MP4";
            height = 720;
            itag = 22;
            outputFilename = "Lil Wayne - She Will ft. Drake [720p].mp4";
            quality = hd720;
            s = "0EB5EB288649655913278F5D38AB2CD79D45456B9CD.995862014F39B5A58912719A4712344E8DB84AB8AB8";
            title = "Lil Wayne - She Will ft. Drake";
            type = "video/mp4; codecs=avc1.64001F, mp4a.40.2";
            url = "https://r15---sn-bvvbax-2iml.googlevideo.com/videoplayback?lmt=1417236324599143&sver=3&sparams=dur%2Cid%2Cip%2Cipbits%2Citag%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cnh%2Cpl%2Cratebypass%2Crequiressl%2Csource%2Cupn%2Cexpire&ipbits=0&expire=1451201206&id=o-AL0YS27EZsY-lvWQVAq_YYK9z7cGVTbHdXu0f59O2_KJ&requiressl=yes&dur=323.895&mm=31&mn=sn-bvvbax-2iml&pl=16&ratebypass=yes&source=youtube&ip=xx&fexp=9416126%2C9420452%2C9422596%2C9423662%2C9424859&ms=au&mt=1451179550&mv=m&itag=22&upn=1IQJzTpYaQc&mime=video%2Fmp4&key=yt6&nh=EAI&signature=BEB288649605913278F5D38AB2CD79D4545659CD.995862014F39B5A58912719A4712344E8DB848BA";
        },
                {
            extension = webm;
            "fallback_host" = "tc.v6.cache3.googlevideo.com";
            format = "360p WebM";
            height = 360;
            itag = 43;
            outputFilename = "Lil Wayne - She Will ft. Drake [360p].webm";
            quality = medium;
            s = "C4BD4BB32543BD2122B0EA71444D1315A0FE1A783E1.D403C564927604166FDAC8CC3E00E1BFB31F80C80C8";
            title = "Lil Wayne - She Will ft. Drake";
            type = "video/webm; codecs=vp8.0, vorbis";
            url = "https://r15---sn-bvvbax-2iml.googlevideo.com/videoplayback?lmt=1314629037323189&sver=3&sparams=dur%2Cid%2Cip%2Cipbits%2Citag%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cnh%2Cpl%2Cratebypass%2Crequiressl%2Csource%2Cupn%2Cexpire&ipbits=0&expire=1451201206&id=o-AL0YS27EZsY-lvWQVAq_YYK9z7cGVTbHdXu0f59O2_KJ&requiressl=yes&dur=0.000&mm=31&mn=sn-bvvbax-2iml&pl=16&ratebypass=yes&source=youtube&ip=xx&fexp=9416126%2C9420452%2C9422596%2C9423662%2C9424859&ms=au&mt=1451179550&mv=m&itag=43&upn=1IQJzTpYaQc&mime=video%2Fwebm&key=yt6&nh=EAI&signature=84BB32543BC2122B0EA71444D1315A0FE1A7D3E1.D403C564927604166FDAC8CC3E00E1BFB31F88C0";
        },
                {
            extension = mp4;
            "fallback_host" = "tc.v2.cache7.googlevideo.com";
            format = "360p MP4";
            height = 360;
            itag = 18;
            outputFilename = "Lil Wayne - She Will ft. Drake [360p].mp4";
            quality = medium;
            s = "4C16C1F3F3E3B65B051BACAF93CCF1916C65BAD1767.310BA3F6B0F61D98014301705A619F42C73C7B93B93";
            title = "Lil Wayne - She Will ft. Drake";
            type = "video/mp4; codecs=avc1.42001E, mp4a.40.2";
            url = "https://r15---sn-bvvbax-2iml.googlevideo.com/videoplayback?lmt=1417236323829380&sver=3&sparams=dur%2Cid%2Cip%2Cipbits%2Citag%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cnh%2Cpl%2Cratebypass%2Crequiressl%2Csource%2Cupn%2Cexpire&ipbits=0&expire=1451201206&id=o-AL0YS27EZsY-lvWQVAq_YYK9z7cGVTbHdXu0f59O2_KJ&requiressl=yes&dur=323.895&mm=31&mn=sn-bvvbax-2iml&pl=16&ratebypass=yes&source=youtube&ip=xx&fexp=9416126%2C9420452%2C9422596%2C9423662%2C9424859&ms=au&mt=1451179550&mv=m&itag=18&upn=1IQJzTpYaQc&mime=video%2Fmp4&key=yt6&nh=EAI&signature=1C1F3F3E3B45B051BACAF93CCF1916C65BAD6767.310BA3F6B0F61D98014301705A619F42C73C739B";
        },
                {
            extension = flv;
            "fallback_host" = "tc.v5.cache6.googlevideo.com";
            format = "240p FLV";
            height = 240;
            itag = 5;
            outputFilename = "Lil Wayne - She Will ft. Drake [240p].flv";
            quality = small;
            s = "7BA9BA721552691CE498939CDE983433B8887576F62.38EBF4FF41B4E980D2DE3B14523C91DE8DF3F339339";
            title = "Lil Wayne - She Will ft. Drake";
            type = "video/x-flv";
            url = "https://r15---sn-bvvbax-2iml.googlevideo.com/videoplayback?itag=5&sver=3&sparams=dur%2Cid%2Cip%2Cipbits%2Citag%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cnh%2Cpl%2Crequiressl%2Csource%2Cupn%2Cexpire&nh=EAI&ipbits=0&upn=1IQJzTpYaQc&expire=1451201206&lmt=1394255591390341&id=o-AL0YS27EZsY-lvWQVAq_YYK9z7cGVTbHdXu0f59O2_KJ&requiressl=yes&dur=323.866&mm=31&mn=sn-bvvbax-2iml&pl=16&source=youtube&mime=video%2Fx-flv&key=yt6&ip=xx&fexp=9416126%2C9420452%2C9422596%2C9423662%2C9424859&ms=au&mt=1451179550&mv=m&signature=6BA721552671CE498939CDE983433B8887579F62.38EBF4FF41B4E980D2DE3B14523C91DE8DF3F933";
        },
                {
            extension = 3gp;
            "fallback_host" = "tc.v4.cache1.googlevideo.com";
            format = "320p 3GP";
            height = 320;
            itag = 36;
            outputFilename = "Lil Wayne - She Will ft. Drake [320p].3gp";
            quality = small;
            s = "23E13E571D58912DD9152101176B182F723EA178034.287116075927FD4454222C64BEC7C81E0A5A76B56B5";
            title = "Lil Wayne - She Will ft. Drake";
            type = "video/3gpp; codecs=mp4v.20.3, mp4a.40.2";
            url = "https://r15---sn-bvvbax-2iml.googlevideo.com/videoplayback?itag=36&sver=3&sparams=dur%2Cid%2Cip%2Cipbits%2Citag%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cnh%2Cpl%2Crequiressl%2Csource%2Cupn%2Cexpire&nh=EAI&ipbits=0&upn=1IQJzTpYaQc&expire=1451201206&lmt=1429001118026615&id=o-AL0YS27EZsY-lvWQVAq_YYK9z7cGVTbHdXu0f59O2_KJ&requiressl=yes&dur=323.964&mm=31&mn=sn-bvvbax-2iml&pl=16&source=youtube&mime=video%2F3gpp&key=yt6&ip=xx&fexp=9416126%2C9420452%2C9422596%2C9423662%2C9424859&ms=au&mt=1451179550&mv=m&signature=83E571D58922DD9152101176B182F723EA171034.287116075927FD4454222C64BEC7C81E0A5A75B6";
        },
                {
            extension = 3gp;
            "fallback_host" = "tc.v7.cache6.googlevideo.com";
            format = "176p 3GP";
            height = 176;
            itag = 17;
            outputFilename = "Lil Wayne - She Will ft. Drake [176p].3gp";
            quality = small;
            s = "E76376510BF043E744ED8FCDB2F96727EBB97DF5CE2.9CBBD2723B5E338529317801E1C56152D3591496496";
            title = "Lil Wayne - She Will ft. Drake";
            type = "video/3gpp; codecs=mp4v.20.3, mp4a.40.2";
            url = "https://r15---sn-bvvbax-2iml.googlevideo.com/videoplayback?itag=17&sver=3&sparams=dur%2Cid%2Cip%2Cipbits%2Citag%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cnh%2Cpl%2Crequiressl%2Csource%2Cupn%2Cexpire&nh=EAI&ipbits=0&upn=1IQJzTpYaQc&expire=1451201206&lmt=1394255352494745&id=o-AL0YS27EZsY-lvWQVAq_YYK9z7cGVTbHdXu0f59O2_KJ&requiressl=yes&dur=323.964&mm=31&mn=sn-bvvbax-2iml&pl=16&source=youtube&mime=video%2F3gpp&key=yt6&ip=xx&fexp=9416126%2C9420452%2C9422596%2C9423662%2C9424859&ms=au&mt=1451179550&mv=m&signature=576510BF04EE744ED8FCDB2F96727EBB97DF3CE2.9CBBD2723B5E338529317801E1C56152D3591694";
        }
    );
    title = "Lil Wayne - She Will ft. Drake";
    videoID = "_7nYuyfkjCk";
    views = 22888597;
    }


    

Heavily based on various clicktoplugin javascript code.

Could easily be incorporated into an iOS app KBYourTube.h/m are the only files needed.

