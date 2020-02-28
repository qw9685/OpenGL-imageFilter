//
//  ViewController.m
//  openGL-加载图片
//
//  Created by mac on 2020/2/25.
//  Copyright © 2020 cc. All rights reserved.
//

#import "ViewController.h"
#import <GLKit/GLKit.h>
#import "ccCollectionView.h"
#import "ccCollectionViewCell.h"

typedef struct {
    GLKVector3 positionCoord;
    GLKVector2 textureCoord;
} SenceVertex;


@interface ViewController ()

@property (nonatomic,strong) UIImageView *imageView;

@property (nonatomic, assign) SenceVertex *vertices;
@property (nonatomic, strong) EAGLContext *context;

@property (nonatomic, strong) CAEAGLLayer* myLayer;
// 用于刷新屏幕
@property (nonatomic, strong) CADisplayLink *displayLink;
// 开始的时间戳
@property (nonatomic, assign) NSTimeInterval startTimeInterval;
// 着色器程序
@property (nonatomic, assign) GLuint program;
// 顶点缓存
@property (nonatomic, assign) GLuint vertexBuffer;
// 纹理 ID
@property (nonatomic, assign) GLuint textureID;


@end

@implementation ViewController

-(void)viewDidLoad{
        
    [self initCollectionView];
    [self initFilter];
    
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [self.view addSubview:imageView];
    self.imageView = imageView;
}

-(void)initCollectionView{
    
    
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"filter.json" ofType:nil];
    NSData *jsonData = [[NSFileManager defaultManager] contentsAtPath:jsonPath];
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:jsonData options:1 error:nil];
    
    ccCollectionView* _collectionView = [[ccCollectionView alloc] initCollectionViewWithItemClass:[ccCollectionViewCell class] headClass:nil footClass:nil];
    _collectionView.frame = CGRectMake(0, self.view.frame.size.height - 100, self.view.frame.size.width, 100);
    
    _collectionView.cc_sizeForItemAtIndexPath(^CGSize(UICollectionViewLayout * _Nonnull layout, NSIndexPath * _Nonnull indexPath) {
        
        return CGSizeMake(40, 40);
        
    }).cc_CollectionDidSelectRowAtIndexPath(^(NSIndexPath * _Nonnull indexPath, UICollectionView * _Nonnull collectionView) {
        
        NSString* name = jsonArray[indexPath.item][@"filter"];
        [self setupShaderProgramWidthName:name];
        
    }).cc_CollectionNumberOfRows(^NSInteger(NSInteger section, UICollectionView * _Nonnull collectionView) {
        return jsonArray.count;
    }).cc_CollectionViewForCell(^UICollectionViewCell * _Nonnull(NSIndexPath * _Nonnull indexPath, UICollectionView * _Nonnull collectionView) {
        ccCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ccCollectionViewCell class]) forIndexPath:indexPath];
        cell.label.text = jsonArray[indexPath.item][@"title"];
        return cell;
    });
    [self.view addSubview:_collectionView];
}


- (void)initFilter{
    
    [self setupCoord];
    [self setupContext];
    [self setupLayer];
    [self bindRenderLayer:self.myLayer];
    [self bindImage:[[NSBundle mainBundle] pathForResource:@"demo.jpg" ofType:nil]];
    [self setupPort];
    [self bindTopBuffer];
    [self setupShaderProgramWidthName:@"Normal"];
    [self startTimer];
}

- (void)removeTimer{
    if (self.displayLink) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
}

- (void)startTimer{
    
    [self removeTimer];
    
    self.startTimeInterval = 0;
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(timeAction)];
    
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    
}

- (void)timeAction {
    //DisplayLink 的当前时间撮
    if (self.startTimeInterval == 0) {
        self.startTimeInterval = self.displayLink.timestamp;
    }
    //使用program
    glUseProgram(self.program);
    //绑定buffer
    glBindBuffer(GL_ARRAY_BUFFER, self.vertexBuffer);
    
    // 传入时间
    CGFloat currentTime = self.displayLink.timestamp - self.startTimeInterval;
    GLuint time = glGetUniformLocation(self.program, "Time");
    glUniform1f(time, currentTime);
    
    // 清除画布
    glClear(GL_COLOR_BUFFER_BIT);
    glClearColor(1, 1, 1, 1);
    
    // 重绘
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    //渲染到屏幕上
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
    
    [self imageFromTextureWithWidth:[self drawableWidth] height:[self drawableHeight]];
    
}

//渲染上下文
- (void)setupContext{
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if (!self.context) {
        self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    }
    
    [EAGLContext setCurrentContext:self.context];
}

//设置图层(CAEAGLLayer)
- (void)setupLayer{
    self.myLayer = [[CAEAGLLayer alloc] init];
    self.myLayer.frame = CGRectMake(0, 50, self.view.frame.size.width, self.view.frame.size.width);
    self.myLayer.contentsScale = [UIScreen mainScreen].scale;
    self.myLayer.opaque = NO; //CALayer默认是透明的，透明的对性能负荷大，故将其关闭
    self.myLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                   // 由应用层来进行内存管理
                                   @(NO),kEAGLDrawablePropertyRetainedBacking,
                                   kEAGLColorFormatRGBA8,kEAGLDrawablePropertyColorFormat,
                                   nil];
    
    
    [self.view.layer addSublayer:self.myLayer];
}

//绑定渲染缓冲区
- (void)bindRenderLayer:(CAEAGLLayer*)layer{
    // 渲染缓冲区、帧缓冲区对象
    GLuint renderBuffer;
    GLuint frameBuffer;
    
    // 获取渲染缓冲区，绑定渲染缓存区以及将渲染缓冲区与layer建立连接
    glGenRenderbuffers(1, &renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, renderBuffer);
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
    
    // 获取帧缓冲区名称， 绑定帧缓冲区以及将渲染缓冲区附着到帧缓冲区上
    glGenFramebuffers(1, &frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, renderBuffer);
}

//设置顶点缓冲区
- (void)bindTopBuffer{
    // 设置顶点缓存区
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    GLsizeiptr bufferSizeBytes = sizeof(SenceVertex) * 4;
    glBufferData(GL_ARRAY_BUFFER, bufferSizeBytes, self.vertices, GL_DYNAMIC_DRAW);
    self.vertexBuffer = vertexBuffer;
}

//初始化坐标
- (void)setupCoord{
    // 开辟顶点数组内存空间
    self.vertices = malloc(sizeof(SenceVertex) * 4);
    // 初始化顶点数据以及纹理坐标
    self.vertices[0] = (SenceVertex){{-1, 1, 0}, {0, 1}};
    self.vertices[1] = (SenceVertex){{-1, -1, 0}, {0, 0}};
    self.vertices[2] = (SenceVertex){{1, 1, 0}, {1, 1}};
    self.vertices[3] = (SenceVertex){{1, -1, 0}, {1, 0}};
}

//读取图片+设置纹理ID
- (void)bindImage:(NSString*)imagePath{
    // 读取图片
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    // 将图片转换成纹理图片
    GLuint textureID = [self createTextureWithImage:image];
    // 设置纹理ID
    self.textureID = textureID;
}

// 设置视口
- (void)setupPort{
    glViewport(0, 0, self.drawableWidth, self.drawableHeight);
}

// 从图片中加载纹理
- (GLuint)createTextureWithImage:(UIImage *)image {
    CGImageRef cgImageRef = [image CGImage];
    GLuint width = (GLuint)CGImageGetWidth(cgImageRef);
    GLuint height = (GLuint)CGImageGetHeight(cgImageRef);
    CGRect rect = CGRectMake(0, 0, width, height);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    void *imageData = malloc(width * height * 4);
    CGContextRef context = CGBitmapContextCreate(imageData, width, height, 8, width * 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGContextTranslateCTM(context, 0, height);
    CGContextScaleCTM(context, 1.0f, -1.0f);
    CGColorSpaceRelease(colorSpace);
    CGContextClearRect(context, rect);
    CGContextDrawImage(context, rect, cgImageRef);
    
    GLuint textureID;
    glGenTextures(1, &textureID);
    glBindTexture(GL_TEXTURE_2D, textureID);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    glBindTexture(GL_TEXTURE_2D, 0);
    
    CGContextRelease(context);
    free(imageData);
    
    return textureID;
}

//设置着色器
- (void)setupShaderProgramWidthName:(NSString *)name {
    GLuint program = [self programWithShaderName:name];
    
    glUseProgram(program);
    
    GLuint positionSlot = glGetAttribLocation(program, "Position");
    GLuint textureSlot = glGetAttribLocation(program, "Texture");
    GLuint textureCoordSlot = glGetAttribLocation(program, "TextureCoord");
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, self.textureID);
    
    glUniform1i(textureSlot, 0);
    
    glEnableVertexAttribArray(positionSlot);
    glVertexAttribPointer(positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, positionCoord));
    
    glEnableVertexAttribArray(textureCoordSlot);
    glVertexAttribPointer(textureCoordSlot, 2, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, textureCoord));
    
    self.program = program;
}

- (GLuint)programWithShaderName:(NSString *)shaderName {
    GLuint vertexShader = [self compileShaderWithName:shaderName type:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShaderWithName:shaderName type:GL_FRAGMENT_SHADER];
    
    GLuint program = glCreateProgram();
    glAttachShader(program, vertexShader);
    glAttachShader(program, fragmentShader);
    
    glLinkProgram(program);
    
    GLint linkSuccess;
    glGetProgramiv(program, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[250];
        glGetProgramInfoLog(program, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSAssert(NO, @"program link 失败 %@", messageString);
        exit(1);
    }
    
    return program;
}

- (GLuint)compileShaderWithName:(NSString *)name type:(GLenum)shaderType {
    NSString *shaderPath = [[NSBundle mainBundle] pathForResource:name ofType:shaderType == GL_VERTEX_SHADER ? @"vsh" : @"fsh" ];
    NSError *error;
    NSString *shaderString = [NSString stringWithContentsOfFile:shaderPath encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSAssert(NO, @"读取shader失败");
        exit(1);
    }
    
    GLuint shader = glCreateShader(shaderType);
    
    const char *shaderStringUTF8 = [shaderString UTF8String];
    int shaderStringLength = (int)[shaderString length];
    glShaderSource(shader, 1, &shaderStringUTF8, &shaderStringLength);
    
    glCompileShader(shader);
    
    GLint compileSuccess;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[250];
        glGetShaderInfoLog(shader, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSAssert(NO, @"shader编译失败： %@", messageString);
        exit(1);
    }
    return shader;
}


// 获取纹理对应的 UIImage，调用前先绑定对应的帧缓存
- (UIImage *)imageFromTextureWithWidth:(int)width height:(int)height {
    int size = width * height * 4;
    GLubyte *buffer = malloc(size);
    glReadPixels(0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, buffer);
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer, size, NULL);
    int bitsPerComponent = 8;
    int bitsPerPixel = 32;
    int bytesPerRow = 4 * width;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    CGImageRef imageRef = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
    
    // 此时的 imageRef 是上下颠倒的，调用 CG 的方法重新绘制一遍，刚好翻转过来
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    free(buffer);
    
    self.imageView.image = image;
    
    return image;
}

// 获取渲染缓存区的宽
- (GLint)drawableWidth {
    GLint backingWith;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWith);
    return backingWith;
}

// 获取渲染缓存区的高
- (GLint)drawableHeight {
    GLint backingHeight;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
    return backingHeight;
}

@end
