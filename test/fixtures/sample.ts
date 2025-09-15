// Sample TypeScript file for LSP testing

// Interface definition
interface User {
  id: number;
  name: string;
  email: string;
  roles: Role[];
  metadata?: Record<string, any>;
}

// Enum definition
enum Role {
  Admin = 'ADMIN',
  User = 'USER',
  Guest = 'GUEST',
}

// Generic class
class Repository<T extends { id: number }> {
  private items: Map<number, T> = new Map();

  add(item: T): void {
    this.items.set(item.id, item);
  }

  get(id: number): T | undefined {
    return this.items.get(id);
  }

  // Incomplete method for completion testing
  findAll(predicate: (item: T) => boolean): T[] {
    const results: T[] = [];
    this.items.forEach((item) => {
      // Test completion here: results.
      if (predicate(item)) {
        results.push(item); // Fixed for valid syntax
      }
    });
    return results;
  }

  // Type error: wrong return type
  count(): string {
    return this.items.size; // Type error: number to string
  }
}

// Async function with generics
async function fetchUsers<T extends User>(endpoint: string, options?: RequestInit): Promise<T[]> {
  const response = await fetch(endpoint, options);

  // Missing null check
  const data = await response.json();

  // Type assertion without validation
  return data as T[];
}

// Union types and type guards
type Result<T> = { success: true; data: T } | { success: false; error: string };

function isSuccess<T>(result: Result<T>): result is { success: true; data: T } {
  return result.success;
}

// Decorator (experimental)
function Logger(target: any, propertyKey: string, descriptor: PropertyDescriptor) {
  const original = descriptor.value;
  descriptor.value = function (...args: any[]) {
    console.log(`Calling ${propertyKey} with args:`, args);
    return original.apply(this, args);
  };
}

// Class with decorators and access modifiers
class UserService {
  private repository: Repository<User>;

  constructor() {
    this.repository = new Repository<User>();
  }

  @Logger
  public async createUser(userData: Partial<User>): Promise<User> {
    // Type error: Partial<User> might not have required fields
    const user: User = {
      id: Date.now(),
      ...userData, // Error: missing required fields
    };

    this.repository.add(user);
    return user;
  }

  // Missing implementation
  public updateUser(id: number, updates: Partial<User>): Promise<User>;
}

// Type inference issues
const processData = (data) => {
  // 'data' implicitly has 'any' type
  return data.map((item) => item.value * 2);
};

// Formatting issues
const badlyFormatted = (x: number, y: number): number => {
  return x + y;
};

// Missing export
interface InternalConfig {
  debug: boolean;
}

// Unused variable
const unusedVariable = 42;

// Export types
export { User, Role, Repository, UserService, Result };
