module.exports = {
  root: true,
  env: {
    es6: true,
    node: true,
  },
  extends: [
    "eslint:recommended",
    "google", // Uses Google's style guide
  ],
  parserOptions: {
    ecmaVersion: 2020, // Ensure this is 2020 or higher to support modern JS syntax
    sourceType: "module",
  },
  rules: {
    // Enforce double quotes as per Google style
    "quotes": ["error", "double"],
    // Enforce 2-space indentation as per Google style
    "indent": ["error", 2],
    // Relax maximum line length
    "max-len": ["error", {code: 120, ignoreUrls: true, ignoreStrings: true, ignoreTemplateLiterals: true, ignoreRegExpLiterals: true}],
    // Disable JSDoc requirement for every function
    "require-jsdoc": "off",
    // Allow single argument arrow functions without parentheses
    "arrow-parens": ["error", "as-needed"],
    // Enforce no spaces inside object curly braces (Google style)
    "object-curly-spacing": ["error", "never"],
    // Allow `let` for variables that might be reassigned (even if not currently)
    "prefer-const": "warn", // Change from error to warn or 'off' if you prefer `let`
  },
};
