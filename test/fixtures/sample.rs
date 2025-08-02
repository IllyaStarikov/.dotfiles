// Sample Rust file for LSP testing with rust-analyzer

use std::collections::HashMap;
use std::io::{self, Write};
use std::sync::{Arc, Mutex};

// Struct with derive macros
#[derive(Debug, Clone, PartialEq)]
pub struct Person {
    name: String,
    age: u32,
    email: Option<String>,
}

impl Person {
    // Constructor
    pub fn new(name: impl Into<String>, age: u32) -> Self {
        Self {
            name: name.into(),
            age,
            email: None,
        }
    }
    
    // Method with mutable self
    pub fn set_email(&mut self, email: String) {
        self.email = Some(email);
    }
    
    // Method with immutable self
    pub fn can_vote(&self) -> bool {
        self.age >= 18
    }
    
    // Intentional error: undefined field
    pub fn get_phone(&self) -> &str {
        &self.phone  // Error: no field `phone`
    }
}

// Generic struct
struct Container<T> {
    items: Vec<T>,
}

impl<T> Container<T> {
    fn new() -> Self {
        Container { items: Vec::new() }
    }
    
    fn add(&mut self, item: T) {
        self.items.push(item);
    }
    
    // Test completion here: self.items.
}

// Trait definition
trait Drawable {
    fn draw(&self);
    
    // Default implementation
    fn description(&self) -> String {
        String::from("A drawable object")
    }
}

// Enum with data
#[derive(Debug)]
enum Message {
    Text(String),
    Image { url: String, width: u32, height: u32 },
    Video(String, u32),  // url, duration
}

impl Message {
    fn process(&self) {
        match self {
            Message::Text(content) => println!("Text: {}", content),
            Message::Image { url, width, height } => {
                println!("Image: {} ({}x{})", url, width, height);
            }
            Message::Video(url, duration) => {
                println!("Video: {} ({} seconds)", url, duration);
            }
            // Missing pattern (potential warning)
        }
    }
}

// Async function
async fn fetch_data(url: &str) -> Result<String, Box<dyn std::error::Error>> {
    // Simulated async operation
    tokio::time::sleep(std::time::Duration::from_millis(100)).await;
    
    // Type error: wrong return type
    Ok(42)  // Should return String
}

// Function with lifetime parameters
fn longest<'a>(x: &'a str, y: &'a str) -> &'a str {
    if x.len() > y.len() {
        x
    } else {
        y
    }
}

// Closure examples
fn closure_examples() {
    let numbers = vec![1, 2, 3, 4, 5];
    
    // Simple closure
    let sum: i32 = numbers.iter().sum();
    
    // Closure with type annotation
    let is_even = |x: &i32| -> bool { x % 2 == 0 };
    
    // Filter and map
    let even_squares: Vec<i32> = numbers
        .iter()
        .filter(|&&x| is_even(&x))
        .map(|&x| x * x)
        .collect();
    
    // Move closure
    let captured = String::from("Hello");
    let print_captured = move || {
        println!("{}", captured);
    };
    
    // Error: captured moved
    println!("{}", captured);  // Error: value moved
}

// Macro definition
macro_rules! create_function {
    ($func_name:ident) => {
        fn $func_name() {
            println!("Called function: {}", stringify!($func_name));
        }
    };
}

create_function!(foo);
create_function!(bar);

// Error handling with ? operator
fn read_config() -> Result<Config, ConfigError> {
    let content = std::fs::read_to_string("config.toml")?;
    let config: Config = toml::from_str(&content)?;
    Ok(config)
}

// Undefined types (errors)
struct Config;
struct ConfigError;

// Formatting test - poorly formatted
fn   poorly_formatted(  x:i32,y:i32  )->i32{x+y}

// Main function
fn main() {
    let mut person = Person::new("Alice", 25);
    person.set_email("alice@example.com".to_string());
    
    // Pattern matching
    let msg = Message::Text("Hello, Rust!".to_string());
    msg.process();
    
    // Error handling
    match read_config() {
        Ok(config) => println!("Config loaded"),
        Err(e) => eprintln!("Error: {}", e),
    }
    
    // Thread safety with Arc and Mutex
    let counter = Arc::new(Mutex::new(0));
    let counter_clone = Arc::clone(&counter);
    
    std::thread::spawn(move || {
        let mut num = counter_clone.lock().unwrap();
        *num += 1;
    });
    
    // Missing semicolon
    println!("Counter: {:?}", counter.lock().unwrap())
    
    // Unreachable code
    return;
    println!("This is unreachable");
}