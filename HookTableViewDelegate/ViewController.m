//
//  ViewController.m
//  HookTableViewDelegate
//
//  Created by Xummer on 2019/8/2.
//  Copyright © 2019 Xummer. All rights reserved.
//

#import "ViewController.h"

#import "MRLogicInjection.h"

@import ObjectiveC.message;

static NSArray * ClassMethodNames(Class c)
{
    NSMutableArray * array = [NSMutableArray array];
    unsigned int methodCount = 0;
    Method * methodList = class_copyMethodList(c, &methodCount);
    unsigned int i;
    for(i = 0; i < methodCount; i++) {
        [array addObject: NSStringFromSelector(method_getName(methodList[i]))];
    }
    
    free(methodList);
    return array;
}

static void printClassWithIndex(id c, NSUInteger i) {
    if (c != object_getClass(NSObject.class) && c != nil) {
        NSLog(@"%@->isa:%@", @(i), object_getClass(c));
        NSLog(@" ClassMethodNames = %@",ClassMethodNames(object_getClass(c)));
        printClassWithIndex(object_getClass(c), i + 1);
    }
}

static void printSuperWithIndex(id c, NSUInteger i) {
    if (c != NSObject.class && c != nil) {
        NSLog(@"%@ %@->super:%@", @(i), object_getClass(c), class_getSuperclass(object_getClass(c)));
        printSuperWithIndex(class_getSuperclass(object_getClass(c)), i + 1);
        
    }
}

static void printClass(id c) {
//    printClassWithIndex(c, 0);
//    printSuperWithIndex(c, 0);
}

@interface KVOFirstViewController: FatherViewController
@end

@implementation KVOFirstViewController

- (void)viewDidLoad {
    [self addKVO];

    [super viewDidLoad];
    
    NSLog(@"%@", self.tableView.delegate);
}

@end

@interface KVOLastViewController: FatherViewController
@end

@implementation KVOLastViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addKVO];
}

@end

@interface FatherViewController() <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSArray *dataSources;
@property (nonatomic, assign) BOOL canGoBack;

@end

@implementation FatherViewController

- (void)addKVO {
//    NSLog(@"self class:%@",[self class]);
    printClass(self);
    
    [self addObserver:self forKeyPath:@"dataSources" options:NSKeyValueObservingOptionNew context:nil];
    
//    NSLog(@"self class:%@",[self class]);
    printClass(self);
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    
}

- (void)dealloc {
//    NSLog(@"self class:%@",[self class]);
    printClass(self);
    
    [self removeObserver:self forKeyPath:@"dataSources"];
    
//    NSLog(@"self class:%@",[self class]);
    printClass(self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [NSString stringWithFormat:@"Native %@", self.class] ;
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.dataSources = @[ @"Push KVO First", @"Push KVO Last", @"Pop"];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"id"];
    tableView.delegate = self;
    self.tableView = tableView;
    
//    NSLog(@"self class:%@",[self class]);
    printClass(self);
    
    tableView.dataSource = self;
    [self.view addSubview:tableView];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return self.dataSources.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"id" forIndexPath:indexPath];
    
    [self configureCell:cell forRowAtIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell
    forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.textLabel.text = self.dataSources[ indexPath.row ];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"indexPath: %@", indexPath);
    
    if (self.canGoBack) {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
    else {
        FatherViewController *vc = nil;
        switch (indexPath.row) {
            case 0:
                vc = [KVOFirstViewController new];
                break;
            case 1:
                vc = [KVOLastViewController new];
                break;
                
            default:
                break;
        }
        if (vc) {
            vc.canGoBack = YES;
            [self presentViewController:vc animated:YES completion:NULL];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSLog(@"2333");
    
    return 60;
}


@end

@interface ViewController()

@end

@implementation ViewController

@end

@interface IBTTableViewDelegate : NSObject <UITableViewDelegate>

@end

@implementation IBTTableViewDelegate

//+ (Class)class {
//    return [IBTTableViewDelegate class];
//}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"hooked tableView: didSelectRowAtIndexPath: %@", indexPath);
    
    SEL sel = @selector(tableView:didSelectRowAtIndexPath:);
    if (__MRSuperImplatationCurrentCMD__(sel)) {
        MRPrepareSendSuper(void, id, id);
        MRSendSuperSelector(sel, tableView, indexPath);
    }
}

@end

@interface UITableView(IBTHook)

@end

@implementation UITableView(IBTHook)

- (void)__IBT_setDelagte:(id <UITableViewDelegate>)delegate {
    NSLog(@"[beta] - %@", delegate);
    MRExtendInstanceLogicWithKey(delegate, @"hooklogic_", @[IBTTableViewDelegate.class]);
    NSLog(@"[beta] = %@", delegate);
    [self __IBT_setDelagte:delegate];
}

@end

#import <objc/runtime.h>

CG_INLINE void
IBTSwizzingMethod(Class _class, SEL _originSelector, SEL _newSelector) {
    Method oriMethod = class_getInstanceMethod(_class, _originSelector);
    Method newMethod = class_getInstanceMethod(_class, _newSelector);
    BOOL isAddedMethod = class_addMethod(_class, _originSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
    if (isAddedMethod) {
        class_replaceMethod(_class, _newSelector, method_getImplementation(oriMethod), method_getTypeEncoding(oriMethod));
    } else {
        method_exchangeImplementations(oriMethod, newMethod);
    }
}

@interface IBTHookLoader : NSObject

@end

@implementation IBTHookLoader

+ (void)load {
    IBTSwizzingMethod([UITableView class], @selector(setDelegate:), @selector(__IBT_setDelagte:));
}

@end
