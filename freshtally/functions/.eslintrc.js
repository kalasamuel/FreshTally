module.exports = {
  root: true,
  env: {
    es6: true,
    node: true,
  },
  extends: [
    "eslint:recommended",
    "google",
  ],
  parserOptions: {
    ecmaVersion: 2020,
    sourceType: "module",
  },
  rules: {
    "quotes": ["error", "double"],
    "indent": ["error", 2],
    "max-len": ["error", {
      "code": 120,
      "ignoreUrls": true,
      "ignoreStrings": true,
      "ignoreTemplateLiterals": true,
      "ignoreRegExpLiterals": true,
    }],
    "require-jsdoc": "off",
    "arrow-parens": ["error", "as-needed"],
    "object-curly-spacing": ["error", "always"],
    "prefer-const": "warn",
    "no-trailing-spaces": "error",
  },
};
