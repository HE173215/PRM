const express = require("express");

const {
  getDashboard,
  getRevenueReport,
  getBookingReport,
  getTopRentedCars,
  getUsers,
  getUserById,
  updateUserStatus,
  getPayments,
  getPaymentById,
} = require("../controllers/adminController");
const { protect, authorize } = require("../middleware/authMiddleware");

const router = express.Router();

router.use(protect, authorize("admin"));

router.get("/dashboard", getDashboard);
router.get("/reports/revenue", getRevenueReport);
router.get("/reports/bookings", getBookingReport);
router.get("/reports/top-cars", getTopRentedCars);

router.get("/users", getUsers);
router.get("/users/:id", getUserById);
router.patch("/users/:id/status", updateUserStatus);

router.get("/payments", getPayments);
router.get("/payments/:id", getPaymentById);

module.exports = router;
