#ifndef _PCRINCLUDES_H_
#define _PCRINCLUDES_H_

//C headers
#include <cstring>
#include <cmath>
#include <cassert>
#include <cerrno>
#include <cstdio>
#include <ctime>
#include <cstdlib>

//C++ headers
#include <string>
#include <vector>
#include <iostream>
#include <memory>
#include <atomic>
#include <sstream>
#include <fstream>
#include <iomanip>
#include <utility>
#include <thread>
#include <map>

//Linux headers
#include <unistd.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <linux/spi/spidev.h>

#include "exceptions.h"
#include "chaistatus.h"
#include "pins.h"
#include "constants.h"
#include "qpcrapplication.h"

#define QPCRApp() static_cast<QPCRApplication&>(Poco::Util::Application::instance())

#endif
