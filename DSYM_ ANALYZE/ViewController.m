//
//  ViewController.m
//  DSYM_ ANALYZE
//
//  Created by Sunny on 16/7/8.
//  Copyright © 2016年 Sunny. All rights reserved.
//

#import "ViewController.h"
#import "SXAnalyze.h"
#import "SXTableView.h"
#import "SXColorView.h"

@interface ViewController ()
<NSTableViewDelegate
,NSTableViewDataSource
,NSTableViewDragFileDelegate
>

@property (weak) IBOutlet NSButton *resetBtn;

@property (weak) IBOutlet NSButton *analyzeBtn;

@property (weak) IBOutlet NSTextField *sbErrorText;

@property (weak) IBOutlet SXColorView *colorView;

@property (weak) IBOutlet SXTableView *sbTableView;
@property (unsafe_unretained) IBOutlet NSTextView *sbResultText;

/// 存 文件名
@property (nonatomic , strong) NSMutableArray * mArrInfo;
/// 存 uuid
@property (nonatomic , strong) NSMutableArray * mArrUUID;

@property (nonatomic , strong) NSMatrix * matrixBtn;

@property (nonatomic , strong) SXAnalyze * analyze;

@property (nonatomic , assign) NSInteger index;

@end

static NSString * const kUUIDIdentififer = @"kUUIDIdentififer";


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    CGSize mSize = self.colorView.frame.size;
    self.matrixBtn = [[NSMatrix alloc] init];
    self.matrixBtn.frame = CGRectMake(5, mSize.height - 70 - 10, mSize.width - 10, 70);
    self.matrixBtn.mode = NSRadioModeMatrix;
    [self.matrixBtn setAction:@selector(selectUUIDAction:)];
    
    NSButtonCell *prototype = [[NSButtonCell alloc] init];
    [prototype setTitle:@"Radio"];
    [prototype setButtonType:NSRadioButton];
    [self.matrixBtn setPrototype:prototype];
    
    for ( int i = 0 ;  i < 3 ; i ++)
    {
        [self.matrixBtn addRow];
    }
    
    for (int i = 0 ;  i < self.matrixBtn.cells.count; i ++)
    {
        NSButtonCell * cell = (NSButtonCell *)self.matrixBtn.cells[i];
        [cell setImagePosition:NSImageLeft];
    }
    
    [self.matrixBtn setAutosizesCells:YES];
    [self.matrixBtn setAutorecalculatesCellSize:YES];
    [self.colorView addSubview:_matrixBtn];
    
    
    
    [self.sbTableView setDragFileDelegate:self];
    
    
    [self setHiddenViews:YES];
}


#pragma  mark - lazyLoad
- (SXAnalyze *)analyze
{
    if (!_analyze) _analyze = [[SXAnalyze alloc] init];
    return _analyze;
}

- (NSMutableArray *)mArrInfo
{
    if (!_mArrInfo) _mArrInfo = [[NSMutableArray alloc] init];
    return _mArrInfo;
}

- (NSMutableArray *)mArrUUID
{
    if (!_mArrUUID) _mArrUUID = [[NSMutableArray alloc] init];
    return _mArrUUID;
}

#pragma  mark -  Respond Actiona
- (void)selectUUIDAction:(id)sender
{
    NSLog(@"sender:%@  selectRow:%ld",sender , self.matrixBtn.selectedRow);
    
    
//    self.sbResultText.string = @"";
}

- (void)setHiddenViews:(BOOL)isHidden
{
    self.index = -1;
    
    [self.colorView setHidden:isHidden];
    
    if (isHidden)
    {
        [self.sbTableView reloadData];
    }
}

- (IBAction)resetAction:(id)sender
{
    [self setHiddenViews:NO];
    
    [self.mArrInfo removeAllObjects];
    [self.mArrUUID removeAllObjects];
    
    self.sbErrorText.stringValue = @"";
    self.sbResultText.string = @"";
    
    [self setHiddenViews:YES];
}


- (IBAction)copyUUIDToTextView:(id)sender
{
    NSString * uuids = [self.mArrUUID componentsJoinedByString:@"\n"];
    
    self.sbResultText.string = [NSString stringWithFormat:@"%@\n%@",self.sbResultText.string , uuids , nil];
}

- (IBAction)analyzeErrorCode:(id)sender
{
    if (self.sbErrorText.stringValue.length)
    {
        if (self.mArrUUID.count)
        {
            __weak typeof(self) weakSelf = self;
            NSString * armv = [SXAnalyze getArmvType:self.mArrUUID[self.matrixBtn.selectedRow]];
            [self.analyze analyzeError:self.sbErrorText.stringValue armv:armv WithSuccess:^(NSString *sucess) {
                weakSelf.sbResultText.string = sucess;
            } failed:^(NSString *fail) {
                [weakSelf showAlertWithMessage:fail];
            }];
        }
        else
        {
            [self showAlertWithMessage:@"请添加app或DSYM文件"];
        }
    }
    else
    {
        [self showAlertWithMessage:@"请输入错误内存地址"];
    }
}

#pragma  mark - tableView
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.mArrInfo.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSString *identifier = [tableColumn identifier];
    if ([identifier isEqualToString:kUUIDIdentififer])
    {
        NSTableCellView * cellView = [tableView makeViewWithIdentifier:kUUIDIdentififer owner:self];
        cellView.textField.stringValue = [self.mArrInfo[row] lastPathComponent];
        cellView.textField.toolTip = cellView.textField.stringValue;
        
        return cellView;
    }
    return nil;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    NSInteger index = self.sbTableView.selectedRow;
    if (index < 0 || index >= self.mArrInfo.count)
    {
        self.index = index;
        return;
    }
    
    self.index = index;
    
    NSString * filePath = self.mArrInfo[self.index];
    __weak typeof(self) weakSelf = self;
    [self.analyze AnalyzeFileUUID:filePath WithSucess:^(NSString *sucess) {
        [weakSelf parseUUIDs:sucess];
        
    }       failed:^(NSString *fail) {
        [weakSelf showAlertWithMessage:fail];
    }];
}

- (void)showAlertWithMessage:(NSString *)mes
{
    NSAlert * alert = [[NSAlert alloc] init];
    [alert setIcon:nil];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert setMessageText:mes];
    [alert runModal];
}

#pragma  mark - dragFileDelegate
- (void)draggedFileFinish:(NSArray *)fileInfos
{
    if (!fileInfos || !fileInfos.count) return;
    
    [self.mArrInfo removeAllObjects];
    for (NSString * filePath in fileInfos)
    {
        if ([SXAnalyze verifyFileExtension:filePath])
        {
            [self.mArrInfo addObject:filePath];
        }
    }
    
    [self setHiddenViews:YES];
}

#pragma  mark - ParseFiles

- (void)parseUUIDs:(NSString *)uuidStr
{
    NSArray * uuids = [SXAnalyze getUUIDFormat:uuidStr];
    
    [self.mArrUUID removeAllObjects];
    
    [self.mArrUUID addObjectsFromArray:uuids];
    
    
    NSInteger num = self.matrixBtn.cells.count;
    
    for (NSInteger i = 0; i < num;  i ++)
    {
        [self.matrixBtn removeRow:0];
    }
    
    for ( int i = 0 ;  i < self.mArrUUID.count ; i ++)
    {
        [self.matrixBtn addRow];
    }
    
    for (int i = 0 ;  i < self.mArrUUID.count; i ++)
    {
        NSButtonCell * cell = (NSButtonCell *)self.matrixBtn.cells[i];
        [cell setTitle:self.mArrUUID[i]];
    }
    [self.matrixBtn selectCellAtRow:0 column:0];
    
    [self setHiddenViews:NO];
}


@end
