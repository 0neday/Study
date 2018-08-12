//
//  ViewController.m
//  Study
//
//  Created by hongs on 8/12/18.
//  Copyright © 2018 hongs. All rights reserved.
//

#import "ViewController.h"
#include <sys/sysctl.h>

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;

@property (weak, nonatomic) IBOutlet UITextField *passwdTextField;
@property (weak, nonatomic) IBOutlet UILabel *notifyLabel;

@property (weak, nonatomic) IBOutlet UIButton *goButton;
@property (weak, nonatomic) IBOutlet UIProgressView *myProgressView;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property NSTimer *myTimer;

@end

@implementation ViewController

double uptime(void);

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.passwdTextField.secureTextEntry = YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        int waitTime;
        [self.goButton setEnabled:NO];
        while ((waitTime = 90 - uptime()) > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.goButton setTitle:[NSString stringWithFormat:@"wait: %ds", waitTime] forState:UIControlStateNormal];
            });
            sleep(1);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.goButton setTitle:@"go" forState:UIControlStateNormal];
            [self.goButton setEnabled:YES];
        });
    });
    
}

- (IBAction)go:(id)sender {
    bool isUserEqual = [@"hongs" isEqualToString:[self.usernameTextField text]];
    bool isPasswdEqual = [@"passwd" isEqualToString:[self.passwdTextField text]];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        
        
        if (@available(iOS 10.0, *)) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                
                self.myTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 repeats:YES block:^(NSTimer * _Nonnull timer) {
                    static int count = 0;
                    count ++;
                    if(count <= 100) {
                        
                        [self.myProgressView setProgress:count/100.0f];
                        [self.progressLabel setText:[NSString stringWithFormat:@"%d %%", count]];
                        
                    }
                    else{
                        count = 0;
                        [self.myTimer invalidate];
                        self.myTimer = nil;
                    }
                    
                }];
                
            });
        }
        else {
            for(int i=0; i<=10; i+=1 ){
                sleep(1);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.myProgressView setProgress:i*0.1f];
                    [self.progressLabel setText:[NSString stringWithFormat:@"%d %%",i*10]];
                });
            }
        }
        
    });
    
    if (isUserEqual && isPasswdEqual){
        
        [self.notifyLabel setText:@"success!"];
    }
    else
        [self.notifyLabel setText:@"failed!"];
    
    
}


- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

double uptime(){
    struct timeval boottime;
    size_t len = sizeof(boottime);
    int mib[2] = { CTL_KERN, KERN_BOOTTIME };
    if( sysctl(mib, 2, &boottime, &len, NULL, 0) < 0 )
    {
        return -1.0;
    }
    time_t bsec = boottime.tv_sec, csec = time(NULL);
    
    return difftime(csec, bsec);
}

@end
