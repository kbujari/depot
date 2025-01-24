#include <iostream>

int main() {
  int n;
  std::cin >> n;

  if (n == 1)
    std::cout << 1;
  else if (n < 4)
    std::cout << "NO SOLUTION";
  else {
    for (auto i = 2; i <= n; i += 2) std::cout << i << " ";
    for (auto i = 1; i <= n; i += 2) std::cout << i << " ";
  }
}
