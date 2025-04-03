#include <iostream>
#include <set>

using ull = unsigned long long;

int main(int argc, char *argv[]) {
  ull n;
  std::cin >> n;

  auto set = std::set<ull>{};

  std::string numstr;
  while (std::getline(std::cin, numstr, ' ')) set.insert(std::stoi(numstr));

  for (auto i = 1; i <= n; i++) {
    if (set.contains(i)) continue;
    std::cout << i;
    break;
  }
}
