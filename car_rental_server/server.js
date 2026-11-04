const express = require("express");
const cors = require("cors");
const dotenv = require("dotenv");

dotenv.config();

const connectDB = require("./src/config/db");

const authRoutes = require("./src/routes/authRoutes");

const carRoutes = require("./src/routes/carRoutes");

const bookingRoutes = require("./src/routes/bookingRoutes");
const adminRoutes = require("./src/routes/adminRoutes");
connectDB();

const app = express();

app.use(cors());
app.use(express.json());

app.get("/", (req, res) => {
  res.status(200).json({
    success: true,
    message: "Car Rental API is running",
  });
});

app.use("/api/auth", authRoutes);

app.use("/api/cars", carRoutes);

app.use("/api/bookings", bookingRoutes);

app.use("/api/admin", adminRoutes);

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
