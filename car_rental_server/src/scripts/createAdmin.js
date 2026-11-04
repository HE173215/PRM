const dotenv = require("dotenv");
const bcrypt = require("bcryptjs");

const connectDB = require("../config/db");
const User = require("../models/User");

dotenv.config();

const createAdmin = async () => {
  try {
    await connectDB();

    const email = process.env.ADMIN_EMAIL;
    const password = process.env.ADMIN_PASSWORD;
    const fullName = process.env.ADMIN_NAME || "System Admin";

    if (!email || !password) {
      console.log("ADMIN_EMAIL and ADMIN_PASSWORD are required");

      process.exit(1);
    }

    const existingAdmin = await User.findOne({
      email: email.toLowerCase(),
    }).select("+password");

    if (existingAdmin) {
      existingAdmin.role = "admin";
      existingAdmin.status = "active";

      const hashedPassword = await bcrypt.hash(password, 10);

      existingAdmin.password = hashedPassword;

      await existingAdmin.save();

      console.log("Admin account updated");
      console.log(`Email: ${email}`);

      process.exit(0);
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    await User.create({
      fullName,
      email,
      password: hashedPassword,
      role: "admin",
      status: "active",
    });

    console.log("Admin account created");
    console.log(`Email: ${email}`);

    process.exit(0);
  } catch (error) {
    console.error("Create admin failed:", error.message);

    process.exit(1);
  }
};

createAdmin();
