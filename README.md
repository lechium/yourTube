# yourTube
native objective-c wrapper for youtube get_video_info & OS X application that is a basic youtube video player / downloader

Use the KBYourTube singleton with the following method to get video details in a KBYTMedia file.

    [[KBYourTube sharedInstance] getVideoDetailsForID:@"_7nYuyfkjCk" completionBlock:^(KBYTMedia *videoDetails) {
    
        NSLog(@"got details successfully: %@", videoDetails);
    
    } failureBlock:^(NSString *error) {

        NSLog(@"fail!: %@", error);

    }];
    
Would yield
    
    got details successfully: <KBYTMedia: 0x618000089830>
	title: 10 Incredible 4K (Ultra HD) Videos
	author: The Daily Conversation
	keywords: 4K,4K+Resolution,Video,Wildlife,Nature,Best,New,Cities,City,Space,ISS,Photography,Resolution,HD,High+Definition,Quality,Film+(Film),England,Australia,Barcelona,Spain,Innsbruck,Ink+Drops,TheDailyConversation,720p,1080p,Videos,TV,Television,Display,Digital,Movie,Ultra+High+Definition+Television,Cinematography+(Invention),Technology,Innovation,Invention,Pixel,Camera,Panasonic,Canon,Filming,Animals,Tiger,Insects,Buildings,Timelapse,Universe,Amazing,Wow,Clear,Beautiful,Cool
	videoID: 6pxRHBw-k8M
	views: 4015220
	duration: 215
	images: {
    high = "https://i.ytimg.com/vi/6pxRHBw-k8M/hqdefault.jpg";
    medium = "https://i.ytimg.com/vi/6pxRHBw-k8M/mqdefault.jpg";
    standard = "https://i.ytimg.com/vi/6pxRHBw-k8M/sddefault.jpg";
    }
	streams: ( "{\n    extension = mp4;\n    format = \"720p MP4\";\n    height = 720;\n    itag = 22;\n    title = \"10 Incredible 4K %28Ultra HD%29 Videos\";\n    type = \"video/mp4; codecs=avc1.64001F, mp4a.40.2\";\n    url = \"https://r5---sn-bvvbax-2iml.googlevideo.com/videoplayback?source=youtube&signature=6D18EC144479B0FF2E94591C30A3DC25DA40BFA3.98B1D5D46514F498A15C0971B3F3F312ADE55FA3&nh=EAI&requiressl=yes&mime=video%2Fmp4&mm=31&mn=sn-bvvbax-2iml&itag=22&mt=1451369898&mv=m&pl=16&ms=au&upn=Sqtq2Z8NA_A&ip=xx&sparams=dur%2Cid%2Cip%2Cipbits%2Citag%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cnh%2Cpl%2Cratebypass%2Crequiressl%2Csource%2Cupn%2Cexpire&ratebypass=yes&sver=3&id=o-AGIrNaf5s3YL6M-V1wrn_eMmsLatKhGolGwJd6If0bUz&ipbits=0&fexp=9406813%2C9407016%2C9415422%2C9416126%2C9418404%2C9420452%2C9422596%2C9423662%2C9424205%2C9425382%2C9425742%2C9425965&lmt=1449732938738301&key=yt6&expire=1451391540&dur=214.343\";\n}",
    "{\n    extension = webm;\n    format = \"360p WebM\";\n    height = 360;\n    itag = 43;\n    title = \"10 Incredible 4K %28Ultra HD%29 Videos\";\n    type = \"video/webm; codecs=vp8.0, vorbis\";\n    url = \"https://r5---sn-bvvbax-2iml.googlevideo.com/videoplayback?source=youtube&signature=9B3A3DAC05D96879F7BCD33EA86E36DD0F3B4A29.824CD6ECDFFF1C06FCC9F6FF6FE0884F9058F3C3&nh=EAI&requiressl=yes&mime=video%2Fwebm&mm=31&mn=sn-bvvbax-2iml&itag=43&mt=1451369898&mv=m&pl=16&ms=au&upn=Sqtq2Z8NA_A&ip=xx&sparams=dur%2Cid%2Cip%2Cipbits%2Citag%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cnh%2Cpl%2Cratebypass%2Crequiressl%2Csource%2Cupn%2Cexpire&ratebypass=yes&sver=3&id=o-AGIrNaf5s3YL6M-V1wrn_eMmsLatKhGolGwJd6If0bUz&ipbits=0&fexp=9406813%2C9407016%2C9415422%2C9416126%2C9418404%2C9420452%2C9422596%2C9423662%2C9424205%2C9425382%2C9425742%2C9425965&lmt=1405835299200982&key=yt6&expire=1451391540&dur=0.000\";\n}",
    "{\n    extension = mp4;\n    format = \"360p MP4\";\n    height = 360;\n    itag = 18;\n    title = \"10 Incredible 4K %28Ultra HD%29 Videos\";\n    type = \"video/mp4; codecs=avc1.42001E, mp4a.40.2\";\n    url = \"https://r5---sn-bvvbax-2iml.googlevideo.com/videoplayback?source=youtube&signature=96FFE106AF2B37992646581330B609AEA4C90AB7.D5ECACAE283E3F24B0281AC511F7C8AE63A1E6F3&nh=EAI&requiressl=yes&mime=video%2Fmp4&mm=31&mn=sn-bvvbax-2iml&itag=18&mt=1451369898&mv=m&pl=16&ms=au&upn=Sqtq2Z8NA_A&ip=xx&sparams=dur%2Cid%2Cip%2Cipbits%2Citag%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cnh%2Cpl%2Cratebypass%2Crequiressl%2Csource%2Cupn%2Cexpire&ratebypass=yes&sver=3&id=o-AGIrNaf5s3YL6M-V1wrn_eMmsLatKhGolGwJd6If0bUz&ipbits=0&fexp=9406813%2C9407016%2C9415422%2C9416126%2C9418404%2C9420452%2C9422596%2C9423662%2C9424205%2C9425382%2C9425742%2C9425965&lmt=1449732801050779&key=yt6&expire=1451391540&dur=214.343\";\n}",
    "{\n    extension = flv;\n    format = \"240p FLV\";\n    height = 240;\n    itag = 5;\n    title = \"10 Incredible 4K %28Ultra HD%29 Videos\";\n    type = \"video/x-flv\";\n    url = \"https://r5---sn-bvvbax-2iml.googlevideo.com/videoplayback?source=youtube&signature=6DAADC89B664C804AEE9B1D47E587DF1AA81D7F5.5F71423279F96C520DD22633D83DE7DE4E819449&sparams=dur%2Cid%2Cip%2Cipbits%2Citag%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cnh%2Cpl%2Crequiressl%2Csource%2Cupn%2Cexpire&sver=3&nh=EAI&requiressl=yes&lmt=1405746379537348&mime=video%2Fx-flv&id=o-AGIrNaf5s3YL6M-V1wrn_eMmsLatKhGolGwJd6If0bUz&ipbits=0&mm=31&mn=sn-bvvbax-2iml&itag=5&mt=1451369898&ip=xx&mv=m&pl=16&fexp=9406813%2C9407016%2C9415422%2C9416126%2C9418404%2C9420452%2C9422596%2C9423662%2C9424205%2C9425382%2C9425742%2C9425965&ms=au&upn=Sqtq2Z8NA_A&key=yt6&expire=1451391540&dur=214.335\";\n}",
    "{\n    extension = 3gp;\n    format = \"320p 3GP\";\n    height = 320;\n    itag = 36;\n    title = \"10 Incredible 4K %28Ultra HD%29 Videos\";\n    type = \"video/3gpp; codecs=mp4v.20.3, mp4a.40.2\";\n    url = \"https://r5---sn-bvvbax-2iml.googlevideo.com/videoplayback?source=youtube&signature=02B3A40B154E64C97EAFB6CC4E1FC8D7C95F2D66.35FA87B1E068DC3C6DCF6A5D10918B8C36A0EFA3&sparams=dur%2Cid%2Cip%2Cipbits%2Citag%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cnh%2Cpl%2Crequiressl%2Csource%2Cupn%2Cexpire&sver=3&nh=EAI&requiressl=yes&lmt=1405746465621216&mime=video%2F3gpp&id=o-AGIrNaf5s3YL6M-V1wrn_eMmsLatKhGolGwJd6If0bUz&ipbits=0&mm=31&mn=sn-bvvbax-2iml&itag=36&mt=1451369898&ip=xx&mv=m&pl=16&fexp=9406813%2C9407016%2C9415422%2C9416126%2C9418404%2C9420452%2C9422596%2C9423662%2C9424205%2C9425382%2C9425742%2C9425965&ms=au&upn=Sqtq2Z8NA_A&key=yt6&expire=1451391540&dur=214.505\";\n}",
    "{\n    extension = 3gp;\n    format = \"176p 3GP\";\n    height = 176;\n    itag = 17;\n    title = \"10 Incredible 4K %28Ultra HD%29 Videos\";\n    type = \"video/3gpp; codecs=mp4v.20.3, mp4a.40.2\";\n    url = \"https://r5---sn-bvvbax-2iml.googlevideo.com/videoplayback?source=youtube&signature=DB745E7D44D06888F6B5A4870FA5CD1781363F18.A8CEF6B35E7E034A611F0D30F650BC2152385B21&sparams=dur%2Cid%2Cip%2Cipbits%2Citag%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cnh%2Cpl%2Crequiressl%2Csource%2Cupn%2Cexpire&sver=3&nh=EAI&requiressl=yes&lmt=1405746450305660&mime=video%2F3gpp&id=o-AGIrNaf5s3YL6M-V1wrn_eMmsLatKhGolGwJd6If0bUz&ipbits=0&mm=31&mn=sn-bvvbax-2iml&itag=17&mt=1451369898&ip=xx&mv=m&pl=16&fexp=9406813%2C9407016%2C9415422%2C9416126%2C9418404%2C9420452%2C9422596%2C9423662%2C9424205%2C9425382%2C9425742%2C9425965&ms=au&upn=Sqtq2Z8NA_A&key=yt6&expire=1451391540&dur=214.459\";\n}",
    "{\n    extension = m4v;\n    format = \"4K M4V\";\n    height = 2160;\n    itag = 138;\n    title = \"10 Incredible 4K (Ultra HD) Videos\";\n    type = \"video/mp4; codecs=avc1.640033\";\n    url = \"https://r5---sn-bvvbax-2iml.googlevideo.com/videoplayback?source=youtube&signature=990961A77734B7BA653D241A0102D62DD3DC2790.A14B5EB933CFF94E39EE0F57196D11497609BE73&nh=EAI&requiressl=yes&clen=349277986&mime=video%2Fmp4&mm=31&mn=sn-bvvbax-2iml&itag=138&mt=1451369898&gir=yes&mv=m&pl=16&ms=au&upn=w-t2V3_p0P4&ip=xx&sparams=clen%2Cdur%2Cgir%2Cid%2Cip%2Cipbits%2Citag%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cnh%2Cpl%2Crequiressl%2Csource%2Cupn%2Cexpire&sver=3&id=o-AGIrNaf5s3YL6M-V1wrn_eMmsLatKhGolGwJd6If0bUz&ipbits=0&fexp=9406813%2C9407016%2C9415422%2C9416126%2C9418404%2C9420452%2C9422596%2C9423662%2C9424205%2C9425382%2C9425742%2C9425965&lmt=1405747091792085&key=yt6&expire=1451391540&dur=214.280\";\n}",
    "{\n    extension = m4v;\n    format = \"4K M4V\";\n    height = 2160;\n    itag = 266;\n    title = \"10 Incredible 4K (Ultra HD) Videos\";\n    type = \"video/mp4; codecs=avc1.640033\";\n    url = \"https://r5---sn-bvvbax-2iml.googlevideo.com/videoplayback?source=youtube&signature=2D9F9CA53625FED1E7027AD9355DE2B0E5499054.4892913D12AEC66136D4AD78D7913C317758CAB0&nh=EAI&requiressl=yes&clen=312153054&mime=video%2Fmp4&mm=31&mn=sn-bvvbax-2iml&itag=266&mt=1451369898&gir=yes&mv=m&pl=16&ms=au&upn=w-t2V3_p0P4&ip=xx&sparams=clen%2Cdur%2Cgir%2Cid%2Cip%2Cipbits%2Citag%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cnh%2Cpl%2Crequiressl%2Csource%2Cupn%2Cexpire&sver=3&id=o-AGIrNaf5s3YL6M-V1wrn_eMmsLatKhGolGwJd6If0bUz&ipbits=0&fexp=9406813%2C9407016%2C9415422%2C9416126%2C9418404%2C9420452%2C9422596%2C9423662%2C9424205%2C9425382%2C9425742%2C9425965&lmt=1449733154041031&key=yt6&expire=1451391540&dur=214.280\";\n}",
    "{\n    extension = m4v;\n    format = \"1440p M4v\";\n    height = 1440;\n    itag = 264;\n    title = \"10 Incredible 4K (Ultra HD) Videos\";\n    type = \"video/mp4; codecs=avc1.640032\";\n    url = \"https://r5---sn-bvvbax-2iml.googlevideo.com/videoplayback?source=youtube&signature=42B32DF08F1D7A509EB4FE71166DD1C75A9F2A21.36EFE8293819E1F94E13BB36DBCE9BC38BDC1543&nh=EAI&requiressl=yes&clen=158364037&mime=video%2Fmp4&mm=31&mn=sn-bvvbax-2iml&itag=264&mt=1451369898&gir=yes&mv=m&pl=16&ms=au&upn=w-t2V3_p0P4&ip=xx&sparams=clen%2Cdur%2Cgir%2Cid%2Cip%2Cipbits%2Citag%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cnh%2Cpl%2Crequiressl%2Csource%2Cupn%2Cexpire&sver=3&id=o-AGIrNaf5s3YL6M-V1wrn_eMmsLatKhGolGwJd6If0bUz&ipbits=0&fexp=9406813%2C9407016%2C9415422%2C9416126%2C9418404%2C9420452%2C9422596%2C9423662%2C9424205%2C9425382%2C9425742%2C9425965&lmt=1449732976047368&key=yt6&expire=1451391540&dur=214.280\";\n}",
    "{\n    extension = m4v;\n    format = \"1080p M4V\";\n    height = 1080;\n    itag = 137;\n    title = \"10 Incredible 4K (Ultra HD) Videos\";\n    type = \"video/mp4; codecs=avc1.640028\";\n    url = \"https://r5---sn-bvvbax-2iml.googlevideo.com/videoplayback?source=youtube&signature=0787C47D19F208CAE4C86A8A1DE437AAE85CEA3E.05DA76A5C47C7FD704766C6BFF4118977D7CB124&nh=EAI&requiressl=yes&clen=66575441&mime=video%2Fmp4&mm=31&mn=sn-bvvbax-2iml&itag=137&mt=1451369898&gir=yes&mv=m&pl=16&ms=au&upn=w-t2V3_p0P4&ip=xx&sparams=clen%2Cdur%2Cgir%2Cid%2Cip%2Cipbits%2Citag%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cnh%2Cpl%2Crequiressl%2Csource%2Cupn%2Cexpire&sver=3&id=o-AGIrNaf5s3YL6M-V1wrn_eMmsLatKhGolGwJd6If0bUz&ipbits=0&fexp=9406813%2C9407016%2C9415422%2C9416126%2C9418404%2C9420452%2C9422596%2C9423662%2C9424205%2C9425382%2C9425742%2C9425965&lmt=1449732892030768&key=yt6&expire=1451391540&dur=214.280\";\n}",
    "{\n    extension = aac;\n    format = \"128K AAC M4A\";\n    height = 0;\n    itag = 140;\n    title = \"10 Incredible 4K (Ultra HD) Videos\";\n    type = \"audio/mp4; codecs=mp4a.40.2\";\n    url = \"https://r5---sn-bvvbax-2iml.googlevideo.com/videoplayback?source=youtube&signature=6AEEB18D8F89CBF7A03F08ECD047982C40373E36.B18CCB0BA17F7C3B7A49C1E7719030B490109AE9&nh=EAI&requiressl=yes&clen=3404889&mime=audio%2Fmp4&mm=31&mn=sn-bvvbax-2iml&itag=140&mt=1451369898&gir=yes&mv=m&pl=16&ms=au&upn=w-t2V3_p0P4&ip=xx&sparams=clen%2Cdur%2Cgir%2Cid%2Cip%2Cipbits%2Citag%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cnh%2Cpl%2Crequiressl%2Csource%2Cupn%2Cexpire&sver=3&id=o-AGIrNaf5s3YL6M-V1wrn_eMmsLatKhGolGwJd6If0bUz&ipbits=0&fexp=9406813%2C9407016%2C9415422%2C9416126%2C9418404%2C9420452%2C9422596%2C9423662%2C9424205%2C9425382%2C9425742%2C9425965&lmt=1449732122591338&key=yt6&expire=1451391540&dur=214.343\";\n}")


Download a video:

    KBYTStream *videoOne = [videoDetails.streams firstObject]; // get first stream
    [downloadFile downloadStream:videoOne progress:^(double percentComplete, NSString *status) {

        //[self setDownloadProgress:percentComplete];
        //self.progressLabel.stringValue = status;
       
    } completed:^(NSString *downloadedFile) {

        //do something with downloadedFile, will be multiplexed / fixed audio file when applicable.
    }];


Scrape search results:

    [[KBYourTube sharedInstance] youTubeSearch:@"Drake rick ross" pageNumber:1 completionBlock:^(NSDictionary *searchDetails) {

    NSLog(@"searchDetails: %@", searchDetails);


    } failureBlock:^(NSString *error) {


    }];


Heavily based on various clicktoplugin javascript code.

For iOS equivalent look at: https://github.com/lechium/yourTubeiOS
