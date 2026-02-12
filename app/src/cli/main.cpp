#include <iostream>
#include <string>
#include <vector>

namespace {

constexpr const char* kVersion = "0.1.0";

void print_usage(std::ostream& out) {
  out << "ReviewCat (reviewcat)\n"
      << "\n"
      << "Usage:\n"
      << "  reviewcat --help\n"
      << "  reviewcat --version\n";
}

}  // namespace

int main(int argc, char** argv) {
  std::vector<std::string> args;
  args.reserve(argc);
  for (int i = 0; i < argc; ++i) {
    args.emplace_back(argv[i] ? argv[i] : "");
  }

  if (argc <= 1) {
    print_usage(std::cout);
    return 0;
  }

  const std::string& cmd = args[1];

  if (cmd == "--help" || cmd == "-h") {
    print_usage(std::cout);
    return 0;
  }

  if (cmd == "--version" || cmd == "-V") {
    std::cout << "reviewcat " << kVersion << "\n";
    return 0;
  }

  std::cerr << "Unknown argument: " << cmd << "\n\n";
  print_usage(std::cerr);
  return 2;
}
