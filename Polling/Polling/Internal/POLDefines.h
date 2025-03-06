//
//  POLDefines.h
//  Polling
//
//  Created by Eddie Hillenbrand on 1/19/25.
//  Copyright © 2025 Polling.com. All rights reserved.
//

#ifndef POL_DEFINES_H
#define POL_DEFINES_H

#define POL_ARRAY_SIZE(x) (sizeof(x)/sizeof(x[0]))

#define POL_NSSTR(cStr) ([NSString stringWithUTF8String:("" #cStr "")])

#if 0
#define POL_LOG_PREFIX_FMT ""			/* none */
#define POL_LOG_PREFIX_FMT "%s "        /* Class Prefix only */
#define POL_LOG_PREFIX_FMT "%s[%s] "	/* Class Prefix & level */
#define POL_LOG_PREFIX_FMT "[%s] "		/* level only */

#define POL_LOG_PREFIX_CONFIG 0x00  /* none */
#define POL_LOG_PREFIX_CONFIG 0x01  /* level */
#define POL_LOG_PREFIX_CONFIG 0x10  /* class prefix */
#define POL_LOG_PREFIX_CONFIG 0x11  /* both */
#endif

#endif /* POL_DEFINES_H */
