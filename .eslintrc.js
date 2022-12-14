module.exports = {
  parser: "@typescript-eslint/parser",
  plugins: [
    "@typescript-eslint",
    "react",
    "jsx-a11y",
    "react-native",
    "jest",
    "simple-import-sort",
    "unused-imports",
  ],
  extends: [
    "eslint:recommended",
    "@react-native-community",
    "plugin:@typescript-eslint/recommended",
    "prettier",
    "plugin:react/recommended",
    "plugin:jsx-a11y/recommended",
  ],
  settings: {
    react: {
      version: "detect",
    },
  },
  env: {
    "jest/globals": true,
  },
  rules: {
    curly: [2, "all"],
    "react/display-name": ["off"],
    "react-native/no-unused-styles": 2,
    "react-native/no-inline-styles": 2,
    "no-console": ["error", { allow: ["warn"] }],
    "@typescript-eslint/explicit-member-accessibility": ["off", "no-public"],
    "@typescript-eslint/explicit-function-return-type": ["off"],
    "@typescript-eslint/no-use-before-define": [
      "error",
      { functions: true, classes: true, variables: false },
    ],
    "@typescript-eslint/camelcase": ["off"],
    "@typescript-eslint/array-type": ["warn", { default: "array-simple" }],
    "@typescript-eslint/interface-name-prefix": ["off"],
    "@typescript-eslint/prefer-interface": ["off"],
    "@typescript-eslint/no-var-requires": ["off"],
    "@typescript-eslint/no-non-null-assertion": ["off"],
    "@typescript-eslint/no-unused-vars": ["off"],
    "@typescript-eslint/ban-ts-ignore": ["off"],
    "unused-imports/no-unused-imports": "error",
    "unused-imports/no-unused-vars": ["warn"],
    "react/no-unescaped-entities": ["off"],
    "jsx-a11y/accessible-emoji": 0, // this rule doesn't really apply to React Native,
    "jsx-a11y/no-autofocus": 0,
    "react/prop-types": ["error", { ignore: ["navigation", "route"] }],
    "no-irregular-whitespace": 0,
    "simple-import-sort/exports": "warn",
    "simple-import-sort/imports": "warn",
  },
  overrides: [
    {
      files: ["*.js", "*.jsx", "*.ts", "*.tsx"],
      rules: {
        "simple-import-sort/imports": [
          "warn",
          {
            groups: [
              ["^react", "^@?\\w"],
              ["^\\u0000"],
              ["^\\.\\.(?!/?$)", "^\\.\\./?$"],
              ["^\\./(?=.*/)(?!/?$)", "^\\.(?!/?$)", "^\\./?$"],
              ["^(@|components|screens|navigation)(/.*|$)"],
              [
                "^(@|api|context|generated|environment|hooks|store|types|utils)(/.*|$)",
              ],
              ["^(@|constants|styles)(/.*|$)"],
            ],
          },
        ],
      },
    },
  ],
  ignorePatterns: ["**/dist/**", "**/plugin/**", "**/__tests__/**"],
};
