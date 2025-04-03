#include <iostream>

int main() {
  std::string input;
  std::cin >> input;

  auto max = 0;
  auto curr = '-';
  auto count = 0;

  for (auto const ch : input) {
    if (curr != ch) {
      curr = ch;
      count = 0;
    }

    count += 1;
    max = std::max(max, count);
  }

  std::cout << max;
  return 0;
}
