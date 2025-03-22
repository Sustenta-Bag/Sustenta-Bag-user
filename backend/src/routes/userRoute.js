import { Router } from "express";

import {
  showUser,
  createUser,
  deleteUser,
  editUser,
  listUsers,
} from "../controllers/userController.js";

const router = Router();
router.get("/:_id", showUser);
router.get("/", listUsers);
router.post("/", createUser);
router.put("/:_id", editUser);
router.delete("/:_id", deleteUser);

export default router;
