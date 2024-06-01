//
//  PVLibRetroGLESCore.h
//  PVRetroArch
//
//  Created by Joseph Mattiello on 6/15/22.
//  Copyright © 2022 Provenance Emu. All rights reserved.
//

#import <Foundation/Foundation.h>

@import PVSupport;
#import <retro/libretro.h>
#import <PVLibRetro/PVLibRetroCore.h>

#pragma clang diagnostic push
#pragma clang diagnostic error "-Wall"

#if !TARGET_OS_MACCATALYST && !TARGET_OS_OSX
#import <OpenGLES/gltypes.h>
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>
#import <OpenGLES/EAGL.h>
#else
#import <OpenGL/OpenGL.h>
#import <GLUT/GLUT.h>
#endif

@interface PVLibRetroGLESCore (ObjC)

@end

#pragma clang diagnostic pop
