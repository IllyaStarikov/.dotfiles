// Sample JavaScript file for LSP testing

// Class with JSDoc comments
/**
 * Calculator class for arithmetic operations
 * @class
 */
class Calculator {
    /**
     * Create a calculator
     * @param {number} initialValue - Initial value
     */
    constructor(initialValue = 0) {
        this.value = initialValue;
        this.history = [];
    }

    /**
     * Add a number to current value
     * @param {number} amount - Amount to add
     * @returns {Calculator} This instance for chaining
     */
    add(amount) {
        this.value += amount;
        this.history.push(`add ${amount}`);
        return this;
    }

    /**
     * Get calculation history
     * @returns {string[]} Array of operations
     */
    getHistory() {
        return [...this.history];
    }

    // Intentional error: undefined variable
    badMethod() {
        return undefinedVariable;
    }
}

// Function with incomplete code for completion testing
function processArray(items) {
    return items.map(item => {
        // Test completion here
        return item.
    });
}

// Async function with error handling
async function fetchData(url) {
    try {
        const response = await fetch(url);
        const data = await response.json();
        
        // Type error: forEach on potentially null
        data.items.forEach(item => {
            console.log(item.name);
        });
        
        return data;
    } catch (error) {
        // Missing return in catch block
        console.error(error);
    }
}

// Arrow function with poor formatting
const   badlyFormatted=(x,y,z)=>{return x+y+z;}

// Test destructuring and spread
const { prop1, prop2, ...rest } = someObject; // someObject not defined

// Module exports
export { Calculator, processArray, fetchData };

// Missing semicolon (depending on linter settings)
const value = 42

// Unreachable code
function testReturn() {
    return true;
    console.log("This is unreachable");
}