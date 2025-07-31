--
-- JavaScript/TypeScript snippets - Modern ES6+ and React patterns
-- Professional templates for full-stack development
--

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local sn = ls.snippet_node

-- Helper functions
local function get_filename()
  return vim.fn.expand('%:t:r') or 'Component'
end

local function get_component_name()
  local filename = vim.fn.expand('%:t:r') or 'Component'
  return filename:gsub("^%l", string.upper)
end

return {
  -- Modern React Functional Component with TypeScript
  s("rfc", {
    t({"import React from 'react';"}),
    t({"import { "}), i(1, "useState, useEffect"), t({" } from 'react';"}),
    t({"import styles from './"}), f(get_filename, {}), t({".module.css';"}),
    t({""}), t({""}),
    t({"interface "}), f(get_component_name, {}), t({"Props {"}),
    t({"  "}), i(2, "title"), t({": string;"}),
    t({"  "}), i(3, "children"), t({"?: React.ReactNode;"}),
    t({"  "}), i(4, "onClick"), t({"?: () => void;"}),
    t({"}"}),
    t({""}), t({""}),
    t({"/**"}),
    t({" * "}), i(5, "Component description"),
    t({" * "}),
    t({" * @example"}),
    t({" * <"}), f(get_component_name, {}), t({" title=\"Example\" onClick={handleClick}>"}),
    t({" *   Content"}),
    t({" * </"}), f(get_component_name, {}), t({">"}),
    t({" */"}),
    t({"export const "}), f(get_component_name, {}), t({": React.FC<"}), f(get_component_name, {}), t({"Props> = ({"}),
    t({"  "}), f(function(args) return args[1][1] end, {2}), t({","}),
    t({"  "}), f(function(args) return args[1][1] end, {3}), t({","}),
    t({"  "}), f(function(args) return args[1][1] end, {4}), t({","}),
    t({"}) => {"}),
    t({"  const ["}), i(6, "state"), t({", set"}), f(function(args) 
      local state = args[1][1]
      return state:gsub("^%l", string.upper)
    end, {6}), t({"] = useState<"}), i(7, "string"), t({">("}), i(8, "''"), t({");"}),
    t({""}),
    t({"  useEffect(() => {"}),
    t({"  "}), i(9, "// Component logic"),
    t({"  }, []);"}),
    t({""}),
    t({"  return ("}),
    t({"    <div className={styles.container}>"}),
    t({"      <h1>{"}), f(function(args) return args[1][1] end, {2}), t({"}</h1>"}),
    t({"      {"}), f(function(args) return args[1][1] end, {3}), t({"}"}),
    t({"    "}), i(10, "// Component JSX"),
    t({"    </div>"}),
    t({"  );"}),
    t({"};"}),
    t({""}),
    t({"export default "}), f(get_component_name, {}), t({";"}),
    i(0)
  }),

  -- Custom React Hook
  s("hook", {
    t({"import { "}), i(1, "useState, useEffect, useCallback"), t({" } from 'react';"}),
    t({""}), t({""}),
    t({"interface Use"}), i(2, "CustomHook"), t({"Options {"}),
    t({"  "}), i(3, "initialValue"), t({"?: "}), i(4, "string"), t({";"}),
    t({"  "}), i(5, "onUpdate"), t({"?: (value: "}), f(function(args) return args[1][1] end, {4}), t({") => void;"}),
    t({"}"}),
    t({""}), t({""}),
    t({"interface Use"}), f(function(args) return args[1][1] end, {2}), t({"Return {"}),
    t({"  "}), i(6, "value"), t({": "}), f(function(args) return args[1][1] end, {4}), t({";"}),
    t({"  "}), i(7, "setValue"), t({": (value: "}), f(function(args) return args[1][1] end, {4}), t({") => void;"}),
    t({"  "}), i(8, "reset"), t({": () => void;"}),
    t({"  "}), i(9, "loading"), t({": boolean;"}),
    t({"}"}),
    t({""}), t({""}),
    t({"/**"}),
    t({" * "}), i(10, "Hook description"),
    t({" * "}),
    t({" * @param options Configuration options"}),
    t({" * @returns Hook state and methods"}),
    t({" * "}),
    t({" * @example"}),
    t({" * const { value, setValue, reset } = use"}), f(function(args) return args[1][1] end, {2}), t({"({"}),
    t({" *   initialValue: 'default',"}),
    t({" *   onUpdate: (val) => console.log(val)"}),
    t({" * });"}),
    t({" */"}),
    t({"export const use"}), f(function(args) return args[1][1] end, {2}), t({" = ("}),
    t({"  options: Use"}), f(function(args) return args[1][1] end, {2}), t({"Options = {}"}),
    t({"): Use"}), f(function(args) return args[1][1] end, {2}), t({"Return => {"}),
    t({"  const { "}), f(function(args) return args[1][1] end, {3}), t({", "}), f(function(args) return args[1][1] end, {5}), t({" } = options;"}),
    t({""}),
    t({"  const ["}), f(function(args) return args[1][1] end, {6}), t({", set"}), f(function(args) 
      local value = args[1][1]
      return value:gsub("^%l", string.upper)
    end, {6}), t({"] = useState<"}), f(function(args) return args[1][1] end, {4}), t({">("}),
    t({"  "}), f(function(args) return args[1][1] end, {3}), t({" ?? "}), i(11, "''"),
    t({"  );"}),
    t({"  const ["}), f(function(args) return args[1][1] end, {9}), t({", set"}), f(function(args) 
      local loading = args[1][1]
      return loading:gsub("^%l", string.upper)
    end, {9}), t({"] = useState(false);"}),
    t({""}),
    t({"  const "}), f(function(args) return args[1][1] end, {7}), t({" = useCallback("}),
    t({"    (newValue: "}), f(function(args) return args[1][1] end, {4}), t({") => {"}),
    t({"      set"}), f(function(args) 
      local value = args[1][1]
      return value:gsub("^%l", string.upper)
    end, {6}), t({"(newValue);"}),
    t({"    "}), f(function(args) return args[1][1] end, {5}), t({"?.(newValue);"}),
    t({"    },"}),
    t({"    ["}), f(function(args) return args[1][1] end, {5}), t({"]"}),
    t({"  );"}),
    t({""}),
    t({"  const "}), f(function(args) return args[1][1] end, {8}), t({" = useCallback(() => {"}),
    t({"  "}), f(function(args) return args[1][1] end, {7}), t({"("}), f(function(args) return args[1][1] end, {3}), t({" ?? "}), f(function(args) return args[1][1] end, {11}), t({");"}),
    t({"  }, ["}), f(function(args) return args[1][1] end, {3}), t({", "}), f(function(args) return args[1][1] end, {7}), t({"]);"}),
    t({""}),
    t({"  useEffect(() => {"}),
    t({"  "}), i(12, "// Hook side effects"),
    t({"  }, ["}), f(function(args) return args[1][1] end, {6}), t({"]);"}),
    t({""}),
    t({"  return {"}),
    t({"  "}), f(function(args) return args[1][1] end, {6}), t({","}),
    t({"  "}), f(function(args) return args[1][1] end, {7}), t({","}),
    t({"  "}), f(function(args) return args[1][1] end, {8}), t({","}),
    t({"  "}), f(function(args) return args[1][1] end, {9}), t({","}),
    t({"  };"}),
    t({"};"}),
    i(0)
  }),

  -- Express.js API Endpoint with TypeScript
  s("express", {
    t({"import { Request, Response, NextFunction } from 'express';"}),
    t({"import { body, validationResult } from 'express-validator';"}),
    t({"import { "}), i(1, "Service"), t({" } from '../services/"}), f(function(args) return args[1][1]:lower() end, {1}), t({".service';"}),
    t({"import { "}), i(2, "Model"), t({" } from '../models/"}), f(function(args) return args[1][1]:lower() end, {2}), t({".model';"}),
    t({"import { AppError } from '../utils/errors';"}),
    t({"import { logger } from '../utils/logger';"}),
    t({""}), t({""}),
    t({"interface "}), i(3, "CreateRequest"), t({" extends Request {"}),
    t({"  body: {"}),
    t({"  "}), i(4, "name"), t({": string;"}),
    t({"  "}), i(5, "email"), t({": string;"}),
    t({"  "}), i(6, "data"), t({"?: any;"}),
    t({"  };"}),
    t({"}"}),
    t({""}), t({""}),
    t({"/**"}),
    t({" * Validation rules for "}), i(7, "creating resource"),
    t({" */"}),
    t({"export const "}), i(8, "createValidation"), t({" = ["}),
    t({"  body('"}), f(function(args) return args[1][1] end, {4}), t({"')"}),
    t({"    .trim()"}),
    t({"    .notEmpty().withMessage('"}), f(function(args) 
      local name = args[1][1]
      return name:gsub("^%l", string.upper) .. " is required"
    end, {4}), t({"')"}),
    t({"    .isLength({ min: 2, max: 100 }).withMessage('"}), f(function(args) 
      local name = args[1][1]
      return name:gsub("^%l", string.upper) .. " must be between 2 and 100 characters"
    end, {4}), t({"'),"}),
    t({"  body('"}), f(function(args) return args[1][1] end, {5}), t({"')"}),
    t({"    .trim()"}),
    t({"    .notEmpty().withMessage('Email is required')"}),
    t({"    .isEmail().withMessage('Invalid email format')"}),
    t({"    .normalizeEmail(),"}),
    t({"];"}),
    t({""}), t({""}),
    t({"/**"}),
    t({" * "}), i(9, "Create a new resource"),
    t({" * "}),
    t({" * @route POST /api/"}), i(10, "resources"),
    t({" * @access "}), c(11, {t("Public"), t("Private"), t("Admin")}),
    t({" */"}),
    t({"export const "}), i(12, "create"), t({" = async ("}),
    t({"  req: "}), f(function(args) return args[1][1] end, {3}), t({","}),
    t({"  res: Response,"}),
    t({"  next: NextFunction"}),
    t({"): Promise<void> => {"}),
    t({"  try {"}),
    t({"    // Check validation errors"}),
    t({"    const errors = validationResult(req);"}),
    t({"    if (!errors.isEmpty()) {"}),
    t({"      throw new AppError('Validation failed', 400, errors.array());"}),
    t({"    }"}),
    t({""}),
    t({"    const { "}), f(function(args) return args[1][1] end, {4}), t({", "}), f(function(args) return args[1][1] end, {5}), t({", "}), f(function(args) return args[1][1] end, {6}), t({" } = req.body;"}),
    t({""}),
    t({"    // Business logic"}),
    t({"    const service = new "}), f(function(args) return args[1][1] end, {1}), t({"();"}),
    t({"    const result = await service."}), f(function(args) return args[1][1] end, {12}), t({"({"}),
    t({"    "}), f(function(args) return args[1][1] end, {4}), t({","}),
    t({"    "}), f(function(args) return args[1][1] end, {5}), t({","}),
    t({"    "}), f(function(args) return args[1][1] end, {6}), t({","}),
    t({"    });"}),
    t({""}),
    t({"    logger.info('"}), i(13, "Resource created"), t({"', { id: result.id });"}),
    t({""}),
    t({"    res.status(201).json({"}),
    t({"      success: true,"}),
    t({"      message: '"}), i(14, "Resource created successfully"), t({"',"}),
    t({"      data: result,"}),
    t({"    });"}),
    t({"  } catch (error) {"}),
    t({"    logger.error('"}), i(15, "Error creating resource"), t({"', error);"}),
    t({"    next(error);"}),
    t({"  }"}),
    t({"};"}),
    t({""}), t({""}),
    t({"/**"}),
    t({" * Get all "}), f(function(args) return args[1][1] end, {10}),
    t({" * "}),
    t({" * @route GET /api/"}), f(function(args) return args[1][1] end, {10}),
    t({" * @access "}), f(function(args) return args[1][1] end, {11}),
    t({" */"}),
    t({"export const getAll = async ("}),
    t({"  req: Request,"}),
    t({"  res: Response,"}),
    t({"  next: NextFunction"}),
    t({"): Promise<void> => {"}),
    t({"  try {"}),
    t({"    const { page = 1, limit = 10, sort = '-createdAt' } = req.query;"}),
    t({""}),
    t({"    const service = new "}), f(function(args) return args[1][1] end, {1}), t({"();"}),
    t({"    const result = await service.findAll({"}),
    t({"      page: Number(page),"}),
    t({"      limit: Number(limit),"}),
    t({"      sort: String(sort),"}),
    t({"    });"}),
    t({""}),
    t({"    res.json({"}),
    t({"      success: true,"}),
    t({"      data: result.data,"}),
    t({"      pagination: result.pagination,"}),
    t({"    });"}),
    t({"  } catch (error) {"}),
    t({"    next(error);"}),
    t({"  }"}),
    t({"};"}),
    i(0)
  }),

  -- Modern Async/Await with Error Handling
  s("async", {
    t({"/**"}),
    t({" * "}), i(1, "Function description"),
    t({" * @param {"}), i(2, "string"), t({"} "}), i(3, "param"), t({" - "}), i(4, "Parameter description"),
    t({" * @returns {Promise<"}), i(5, "any"), t({">} "}), i(6, "Return description"),
    t({" */"}),
    t({"export const "}), i(7, "functionName"), t({" = async ("}), f(function(args) return args[1][1] end, {3}), t({": "}), f(function(args) return args[1][1] end, {2}), t({"): Promise<"}), f(function(args) return args[1][1] end, {5}), t({"> => {"}),
    t({"  try {"}),
    t({"  "}), i(8, "// Async operation"),
    t({"    const result = await "}), i(9, "someAsyncOperation()"), t({";"}),
    t({"  "}),
    t({"    // Validation"}),
    t({"    if (!result) {"}),
    t({"      throw new Error('"}), i(10, "No result found"), t({"');"}),
    t({"    }"}),
    t({"  "}),
    t({"    return result;"}),
    t({"  } catch (error) {"}),
    t({"    console.error('Error in "}), f(function(args) return args[1][1] end, {7}), t({":', error);"}),
    t({"    throw error;"}),
    t({"  }"}),
    t({"};"}),
    i(0)
  }),

  -- Jest Test Suite
  s("test", {
    t({"import { describe, it, expect, beforeEach, afterEach, jest } from '@jest/globals';"}),
    t({"import { "}), i(1, "functionToTest"), t({" } from './"}), i(2, "module"), t({"';"}),
    t({""}), t({""}),
    t({"describe('"}), f(function(args) return args[1][1] end, {1}), t({"', () => {"}),
    t({"  let "}), i(3, "mockData"), t({";"}),
    t({""}),
    t({"  beforeEach(() => {"}),
    t({"  "}), i(4, "// Setup before each test"),
    t({"  "}), f(function(args) return args[1][1] end, {3}), t({" = "}), i(5, "{ id: 1, name: 'test' }"), t({";"}),
    t({"    jest.clearAllMocks();"}),
    t({"  });"}),
    t({""}),
    t({"  afterEach(() => {"}),
    t({"  "}), i(6, "// Cleanup after each test"),
    t({"  });"}),
    t({""}),
    t({"  describe('"}), i(7, "when called with valid input"), t({"', () => {"}),
    t({"    it('"}), i(8, "should return expected result"), t({"', async () => {"}),
    t({"      // Arrange"}),
    t({"      const input = "}), i(9, "'test input'"), t({";"}),
    t({"      const expected = "}), i(10, "'expected output'"), t({";"}),
    t({""}),
    t({"      // Act"}),
    t({"      const result = await "}), f(function(args) return args[1][1] end, {1}), t({"(input);"}),
    t({""}),
    t({"      // Assert"}),
    t({"      expect(result).toBe(expected);"}),
    t({"    });"}),
    t({""}),
    t({"    it('"}), i(11, "should handle edge case"), t({"', async () => {"}),
    t({"      // Test edge case"}),
    t({"    "}), i(12, "expect(functionToTest(null)).toThrow()"), t({";"}),
    t({"    });"}),
    t({"  });"}),
    t({""}),
    t({"  describe('"}), i(13, "when called with invalid input"), t({"', () => {"}),
    t({"    it('"}), i(14, "should throw an error"), t({"', async () => {"}),
    t({"      // Arrange"}),
    t({"      const invalidInput = "}), i(15, "null"), t({";"}),
    t({""}),
    t({"      // Act & Assert"}),
    t({"      await expect("}), f(function(args) return args[1][1] end, {1}), t({"(invalidInput))"}),
    t({"        .rejects.toThrow('"}), i(16, "Expected error message"), t({"');"}),
    t({"    });"}),
    t({"  });"}),
    t({"});"}),
    i(0)
  }),

  -- Redux Slice with TypeScript
  s("slice", {
    t({"import { createSlice, PayloadAction } from '@reduxjs/toolkit';"}),
    t({"import { RootState } from '../../store';"}),
    t({""}), t({""}),
    t({"interface "}), i(1, "Feature"), t({"State {"}),
    t({"  "}), i(2, "data"), t({": "}), i(3, "any[]"), t({";"}),
    t({"  "}), i(4, "loading"), t({": boolean;"}),
    t({"  "}), i(5, "error"), t({": string | null;"}),
    t({"  "}), i(6, "selected"), t({"?: "}), i(7, "string"), t({";"}),
    t({"}"}),
    t({""}), t({""}),
    t({"const initialState: "}), f(function(args) return args[1][1] end, {1}), t({"State = {"}),
    t({"  "}), f(function(args) return args[1][1] end, {2}), t({": [],"}),
    t({"  "}), f(function(args) return args[1][1] end, {4}), t({": false,"}),
    t({"  "}), f(function(args) return args[1][1] end, {5}), t({": null,"}),
    t({"  "}), f(function(args) return args[1][1] end, {6}), t({": undefined,"}),
    t({"};"}),
    t({""}), t({""}),
    t({"const "}), i(8, "feature"), t({"Slice = createSlice({"}),
    t({"  name: '"}), f(function(args) return args[1][1] end, {8}), t({"',"}),
    t({"  initialState,"}),
    t({"  reducers: {"}),
    t({"    // Sync actions"}),
    t({"    set"}), f(function(args) 
      local data = args[1][1]
      return data:gsub("^%l", string.upper)
    end, {2}), t({"(state, action: PayloadAction<"}), f(function(args) return args[1][1] end, {3}), t({">) {"}),
    t({"      state."}), f(function(args) return args[1][1] end, {2}), t({" = action.payload;"}),
    t({"    },"}),
    t({"    set"}), f(function(args) 
      local selected = args[1][1]
      return selected:gsub("^%l", string.upper)
    end, {6}), t({"(state, action: PayloadAction<"}), f(function(args) return args[1][1] end, {7}), t({">) {"}),
    t({"      state."}), f(function(args) return args[1][1] end, {6}), t({" = action.payload;"}),
    t({"    },"}),
    t({"    clearError(state) {"}),
    t({"      state."}), f(function(args) return args[1][1] end, {5}), t({" = null;"}),
    t({"    },"}),
    t({"    // Async action lifecycle"}),
    t({"    fetch"}), f(function(args) 
      local data = args[1][1]
      return data:gsub("^%l", string.upper)
    end, {2}), t({"Start(state) {"}),
    t({"      state."}), f(function(args) return args[1][1] end, {4}), t({" = true;"}),
    t({"      state."}), f(function(args) return args[1][1] end, {5}), t({" = null;"}),
    t({"    },"}),
    t({"    fetch"}), f(function(args) 
      local data = args[1][1]
      return data:gsub("^%l", string.upper)
    end, {2}), t({"Success(state, action: PayloadAction<"}), f(function(args) return args[1][1] end, {3}), t({">) {"}),
    t({"      state."}), f(function(args) return args[1][1] end, {4}), t({" = false;"}),
    t({"      state."}), f(function(args) return args[1][1] end, {2}), t({" = action.payload;"}),
    t({"    },"}),
    t({"    fetch"}), f(function(args) 
      local data = args[1][1]
      return data:gsub("^%l", string.upper)
    end, {2}), t({"Failure(state, action: PayloadAction<string>) {"}),
    t({"      state."}), f(function(args) return args[1][1] end, {4}), t({" = false;"}),
    t({"      state."}), f(function(args) return args[1][1] end, {5}), t({" = action.payload;"}),
    t({"    },"}),
    t({"  },"}),
    t({"});"}),
    t({""}), t({""}),
    t({"// Actions"}),
    t({"export const {"}),
    t({"  set"}), f(function(args) 
      local data = args[1][1]
      return data:gsub("^%l", string.upper)
    end, {2}), t({","}),
    t({"  set"}), f(function(args) 
      local selected = args[1][1]
      return selected:gsub("^%l", string.upper)
    end, {6}), t({","}),
    t({"  clearError,"}),
    t({"  fetch"}), f(function(args) 
      local data = args[1][1]
      return data:gsub("^%l", string.upper)
    end, {2}), t({"Start,"}),
    t({"  fetch"}), f(function(args) 
      local data = args[1][1]
      return data:gsub("^%l", string.upper)
    end, {2}), t({"Success,"}),
    t({"  fetch"}), f(function(args) 
      local data = args[1][1]
      return data:gsub("^%l", string.upper)
    end, {2}), t({"Failure,"}),
    t({"} = "}), f(function(args) return args[1][1] end, {8}), t({"Slice.actions;"}),
    t({""}), t({""}),
    t({"// Selectors"}),
    t({"export const select"}), f(function(args) 
      local feature = args[1][1]
      return feature:gsub("^%l", string.upper)
    end, {8}), t({" = (state: RootState) => state."}), f(function(args) return args[1][1] end, {8}), t({";"}),
    t({"export const select"}), f(function(args) 
      local data = args[1][1]
      return data:gsub("^%l", string.upper)
    end, {2}), t({" = (state: RootState) => state."}), f(function(args) return args[1][1] end, {8}), t({"."}), f(function(args) return args[1][1] end, {2}), t({";"}),
    t({"export const select"}), f(function(args) 
      local selected = args[1][1]
      return selected:gsub("^%l", string.upper)
    end, {6}), t({" = (state: RootState) => state."}), f(function(args) return args[1][1] end, {8}), t({"."}), f(function(args) return args[1][1] end, {6}), t({";"}),
    t({"export const selectIs"}), f(function(args) 
      local loading = args[1][1]
      return loading:gsub("^%l", string.upper)
    end, {4}), t({" = (state: RootState) => state."}), f(function(args) return args[1][1] end, {8}), t({"."}), f(function(args) return args[1][1] end, {4}), t({";"}),
    t({"export const select"}), f(function(args) 
      local error = args[1][1]
      return error:gsub("^%l", string.upper)
    end, {5}), t({" = (state: RootState) => state."}), f(function(args) return args[1][1] end, {8}), t({"."}), f(function(args) return args[1][1] end, {5}), t({";"}),
    t({""}), t({""}),
    t({"// Thunk for async operations"}),
    t({"export const fetch"}), f(function(args) 
      local data = args[1][1]
      return data:gsub("^%l", string.upper)
    end, {2}), t({" = () => async (dispatch: any) => {"}),
    t({"  dispatch(fetch"}), f(function(args) 
      local data = args[1][1]
      return data:gsub("^%l", string.upper)
    end, {2}), t({"Start());"}),
    t({"  try {"}),
    t({"    const response = await fetch('/api/"}), f(function(args) return args[1][1] end, {8}), t({"');"}),
    t({"    const data = await response.json();"}),
    t({"    dispatch(fetch"}), f(function(args) 
      local data = args[1][1]
      return data:gsub("^%l", string.upper)
    end, {2}), t({"Success(data));"}),
    t({"  } catch (error) {"}),
    t({"    dispatch(fetch"}), f(function(args) 
      local data = args[1][1]
      return data:gsub("^%l", string.upper)
    end, {2}), t({"Failure(error.message));"}),
    t({"  }"}),
    t({"};"}),
    t({""}), t({""}),
    t({"export default "}), f(function(args) return args[1][1] end, {8}), t({"Slice.reducer;"}),
    i(0)
  }),

  -- Simple snippets
  s("cl", {
    t({"console.log("}), i(1), t({");"}), i(0)
  }),

  s("imp", {
    t({"import "}), i(1, "{ Component }"), t({" from '"}), i(2, "module"), t({"';"}), i(0)
  }),

  s("exp", {
    t({"export "}), c(1, {t("default"), t("const"), t("function"), t("class")}), t({" "}), i(2, "name"), t({";"}), i(0)
  }),

  s("arr", {
    t({"const "}), i(1, "arr"), t({" = ["}), i(2), t({"];"}), i(0)
  }),

  s("obj", {
    t({"const "}), i(1, "obj"), t({" = {"}),
    t({"  "}), i(2, "key"), t({": "}), i(3, "value"), t({","}),
    t({"};"}), i(0)
  }),

  s("des", {
    t({"const { "}), i(1, "prop"), t({" } = "}), i(2, "object"), t({";"}), i(0)
  }),

  s("promise", {
    t({"new Promise((resolve, reject) => {"}),
    t({"  "}), i(1, "// async operation"),
    t({"});"}), i(0)
  }),

  s("map", {
    i(1, "array"), t({".map(("}), i(2, "item"), t({") => "}), i(3, "item"), t({");"}), i(0)
  }),

  s("filter", {
    i(1, "array"), t({".filter(("}), i(2, "item"), t({") => "}), i(3, "item > 0"), t({");"}), i(0)
  }),

  s("reduce", {
    i(1, "array"), t({".reduce(("}), i(2, "acc"), t({", "}), i(3, "curr"), t({") => "}), i(4, "acc + curr"), t({", "}), i(5, "0"), t({");"}), i(0)
  }),
}