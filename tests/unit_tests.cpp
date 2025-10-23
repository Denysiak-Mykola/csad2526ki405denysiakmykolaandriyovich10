#include <iostream>
#include <gtest/gtest.h>
#include "../math_operations.h"

TEST(AdditionBasic, PositiveNumbers) {
    EXPECT_EQ(add(1, 2), 3);
}

TEST(AdditionBasic, Zero) {
    EXPECT_EQ(add(0, 0), 0);
}

TEST(AdditionBasic, NegAndPos) {
    EXPECT_EQ(add(-1, 1), 0);
}

TEST(AdditionBasic, MixedLarge) {
    EXPECT_EQ(add(100, -50), 50);
}

TEST(AdditionBasic, BothNegative) {
    EXPECT_EQ(add(-5, -7), -12);
}

TEST(AdditionProperties, Commutative) {
    EXPECT_EQ(add(7, 4), add(4, 7));
}

int main(int argc, char** argv) {
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}