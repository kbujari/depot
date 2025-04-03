#include <iostream>
#include <vector>

using ull = unsigned long long;

int main() {
  ull n;
  auto arr = std::vector<ull>{};

  std::cin >> n;

  std::string type;
  while (std::cin >> type) arr.push_back(std::stoi(type));

  ull count = 0;
  auto last = arr[0];

  for (auto const num : arr) {
    if (num > last) {
      last = num;
      continue;
    }
    count += last - num;
  }

  std::cout << count;
}
