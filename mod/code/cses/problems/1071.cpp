#include <iostream>
#include <tuple>
#include <vector>

using ull = unsigned long long;

int main() {
  int n;
  std::cin >> n;

  while (n--) {
    ull x, y;
    std::cin >> y >> x;

    auto area = y * y;
    auto perimeter = y + y + 1;
    auto max = area + perimeter;
  }
}
