// Sample C++ file for LSP testing with clangd
#include <algorithm>
#include <iostream>
#include <map>
#include <memory>
#include <string>
#include <vector>

// Template class for testing
template <typename T>
class Container {
 private:
  std::vector<T> items;
  mutable size_t access_count = 0;

 public:
  Container() = default;

  // Add item to container
  void add(const T& item) { items.push_back(item); }

  // Add item with move semantics
  void add(T&& item) { items.push_back(std::move(item)); }

  // Get item at index
  const T& get(size_t index) const {
    ++access_count;
    return items.at(index);  // May throw std::out_of_range
  }

  // Get container size
  [[nodiscard]] size_t size() const noexcept { return items.size(); }

  // Iterator support
  auto begin() { return items.begin(); }
  auto end() { return items.end(); }
  auto begin() const { return items.cbegin(); }
  auto end() const { return items.cend(); }

  // Intentional error: undefined member function
  void undefined_method() {
    undefined_variable = 42;  // Error: undefined variable
  }
};

// Class with inheritance
class Shape {
 public:
  virtual ~Shape() = default;
  virtual double area() const = 0;
  virtual void draw() const = 0;
};

class Rectangle : public Shape {
 private:
  double width_, height_;

 public:
  Rectangle(double w, double h) : width_(w), height_(h) {}

  double area() const override { return width_ * height_; }

  void draw() const override {
    std::cout << "Drawing rectangle: " << width_ << "x" << height_ << "\n";
  }

  // Missing override keyword (potential warning)
  virtual double perimeter() const { return 2 * (width_ + height_); }
};

// Function with auto return type
auto process_data(const std::vector<int>& data) {
  std::map<std::string, int> result;

  // Test completion here: std::

  for (const auto& value : data) {
    if (value % 2 == 0) {
      result["even"] += 1;
    } else {
      result["odd"] += 1;
    }
  }

  // Type error: returning wrong type
  return data;  // Should return result
}

// Template function
template <typename InputIt, typename UnaryPredicate>
auto count_matching(InputIt first, InputIt last, UnaryPredicate pred) {
  return std::count_if(first, last, pred);
}

// Formatting test - poorly formatted function
void poorly_formatted(int x, int y, int z) {
  int result = x + y + z;
  return;
}

// Modern C++ features
class ModernClass {
  std::unique_ptr<int[]> data;
  size_t size_;

 public:
  // Constructor with initializer list
  ModernClass(std::initializer_list<int> init)
      : data(std::make_unique<int[]>(init.size())), size_(init.size()) {
    std::copy(init.begin(), init.end(), data.get());
  }

  // Rule of 5
  ModernClass(const ModernClass&) = delete;
  ModernClass& operator=(const ModernClass&) = delete;
  ModernClass(ModernClass&&) = default;
  ModernClass& operator=(ModernClass&&) = default;
  ~ModernClass() = default;

  // Range-based for loop support
  int* begin() { return data.get(); }
  int* end() { return data.get() + size_; }
};

// Constexpr function
constexpr int factorial(int n) { return (n <= 1) ? 1 : n * factorial(n - 1); }

// Main function
int main() {
  // Test container
  Container<std::string> strings;
  strings.add("Hello");
  strings.add("World");

  // Test shape hierarchy
  auto rect = std::make_unique<Rectangle>(10.0, 5.0);
  std::cout << "Area: " << rect->area() << std::endl;

  // Test modern features
  ModernClass modern{1, 2, 3, 4, 5};

  // Lambda expression
  auto is_positive = [](int x) { return x > 0; };

  std::vector<int> numbers{-2, -1, 0, 1, 2, 3};
  auto positive_count = count_matching(numbers.begin(), numbers.end(), is_positive);

  // Structured binding (C++17)
  auto [key, value] = *result.begin();  // Error: result not in scope

  // Missing semicolon
  std::cout << "Positive numbers: " << positive_count
            << "\n"

      return 0;
}
