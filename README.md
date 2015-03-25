# YHCT
利用CoreText实现的图文混排组件，适合聊天界面、Timeline等。可自动解析手机号码、超链接，也可以自定义点击事件。长按会弹出复制、举报（自定义菜单项）。

使用方法：

1、初始化

    self.yhTextView = [[YHCoreTextView alloc] initWithFrame:CGRectMake(nameLeft, 12, self.width-8-12, 25)];
    
    self.yhTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin;
    
    [self addSubview:self.yhTextView];
    
2、赋值

    NSString text = @"手机号码1862345543233444超链接https://www.apple.com自动[ok]解析[hello]表[下雨]图片，如果中括号中的图片找不多，会原封不动的显示字符串[duang].";
    
    YHCTData *nameData = [YHCTData instanceYHCTDataWith:text originText:text];
    
    [nameData useDefaultSetting];//使用默认设置
    
    self.yhTextView.yhctData = nameData;

3、事件捕捉
    void(^linkClickAction)(YHCTLinkData* linkData) = ^(YHCTLinkData* linkData){
    
        NSString *action = linkData.action;
        
        if ([action isEqualToString:@"http"] || [action isEqualToString:@"https"]){
        
            NSString *url = [NSString stringWithFormat:@"%@://%@",action,linkData.query];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"打开网页" message:url delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
            
            [alert show];
            
        }else if ([action isEqualToString:@"tel"]){
        
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"拨打电话" message:linkData.query delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
 
            [alert show];
            
        }else {
        
            NSString *msg = [NSString stringWithFormat:@"action:%@ params:%@",linkData.action,linkData.query];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"自定义" message:msg delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
            
            [alert show];
            
        }
        
    };
    
    self.yhTextView.linkClickAction = linkClickAction;
    
    self.yhTextView.otherMenus = @[@"收藏",@"举报"];
    
    self.yhTextView.otherMenuClickAction = ^(NSString *title){
    
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:title delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        
        [alert show];
        
    };
