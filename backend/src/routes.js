import { Router } from "express";

import InternalServerError from "./routes/helper/500.js"
import NotFound from "./routes/helper/404.js";

import userRoute from './routes/userRoute.js'

const routes = Router()
  .use("/api/users/",userRoute)
  .use(InternalServerError)
  .use(NotFound);

export default routes;
