import User from "../models/userModel.js";
import httpStatus from "http-status";

export const showUser = async (req, res, next) => {
  try {
    const user = await User.findOne(req.params);
    res.status(httpStatus.OK).json(user);
  } catch (err) {
    res.httpStatus(httpStatus.INTERNAL_SERVER_ERROR).json({
      message: err.message,
    });
  }
};

export const listUsers = async (req, res, next) => {
  try {
    const user = await User.find(req.params);
    res.status(httpStatus.OK).json(user);
  } catch (err) {
    res.httpStatus(httpStatus.INTERNAL_SERVER_ERROR).json({
      message: err.message,
    });
  }
};

export const createUser = async (req, res, next) => {
  try {
    await new User(req.body).save();
    res.status(httpStatus.OK).json(httpStatus.CREATED);
  } catch (err) {
    res.httpStatus(httpStatus.INTERNAL_SERVER_ERROR).json({
      message: err.message,
    });
  }
};

export const editUser = async (req, res, next) => {
  try {
    await new User(req.params).updateOne(req.body)
    
    res.status(httpStatus.OK).json(httpStatus.CREATED);
  } catch (err) {
    res.httpStatus(httpStatus.INTERNAL_SERVER_ERROR).json({
      message: err.message,
    });
  }
};

export const deleteUser = async (req, res, next) => {
  try {
    await new User(req.params).deleteOne();
    res.status(httpStatus.OK).json(httpStatus.OK);
  } catch (err) {
    res.httpStatus(httpStatus.INTERNAL_SERVER_ERROR).json({
      message: err.message,
    });
  }
};
