#define CATCH_CONFIG_MAIN

#import "catch.hpp"

extern "C" {
#import "test_backend.cpp"
}
#import "test_types.mm"
#import "test_middleware.mm"
