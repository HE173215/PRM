const express = require("express");

const {
  createBooking,
  getMyBookings,
  getBookingById,
  cancelBooking,
  getAllBookings,
  updateBookingStatus,
  markBookingAsPaid,
} = require("../controllers/bookingController");

const { protect, authorize } = require("../middleware/authMiddleware");

const router = express.Router();

router.use(protect);

// CUSTOMER
router.post("/", createBooking);

router.get("/my", getMyBookings);

// ADMIN
router.get("/", authorize("admin"), getAllBookings);
router.get("/admin/all", authorize("admin"), getAllBookings);

router.patch("/:id/status", authorize("admin"), updateBookingStatus);
router.patch("/admin/:id/status", authorize("admin"), updateBookingStatus);

router.patch("/:id/pay", markBookingAsPaid);

// Keep /:id after specific routes.
router.get("/:id", getBookingById);

router.patch("/:id/cancel", cancelBooking);

module.exports = router;
