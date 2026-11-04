const mongoose = require("mongoose");
const Booking = require("../models/Booking");
const Car = require("../models/Car");
const User = require("../models/User");

const bookingStatuses = [
  "pending",
  "confirmed",
  "ongoing",
  "completed",
  "cancelled",
];

const escapeRegex = (value) => value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");

const createBooking = async (req, res) => {
  try {
    const { carId, startDate, endDate, note } = req.body;

    if (!carId || !startDate || !endDate) {
      return res.status(400).json({
        success: false,
        message: "Car, start date and end date are required",
      });
    }

    const car = await Car.findById(carId);

    if (!car) {
      return res.status(404).json({
        success: false,
        message: "Car not found",
      });
    }

    if (car.status !== "available") {
      return res.status(400).json({
        success: false,
        message: "Car is not available for booking",
      });
    }

    const start = new Date(startDate);
    const end = new Date(endDate);

    if (Number.isNaN(start.getTime()) || Number.isNaN(end.getTime())) {
      return res.status(400).json({
        success: false,
        message: "Invalid date",
      });
    }

    if (end <= start) {
      return res.status(400).json({
        success: false,
        message: "End date must be after start date",
      });
    }

    if (start < new Date()) {
      return res.status(400).json({
        success: false,
        message: "Start date cannot be in the past",
      });
    }

    const overlappingBooking = await Booking.findOne({
      car: carId,

      status: {
        $in: ["pending", "confirmed", "ongoing"],
      },

      startDate: {
        $lt: end,
      },

      endDate: {
        $gt: start,
      },
    });

    if (overlappingBooking) {
      return res.status(409).json({
        success: false,
        message: "Car is not available for the selected dates",
      });
    }

    const millisecondsPerDay = 1000 * 60 * 60 * 24;

    const totalDays = Math.ceil((end - start) / millisecondsPerDay);

    const pricePerDay = car.pricePerDay;

    const totalAmount = totalDays * pricePerDay;

    const booking = await Booking.create({
      user: req.user._id,
      car: car._id,

      startDate: start,
      endDate: end,

      pricePerDay,
      totalDays,
      totalAmount,

      note: note?.trim() || "",
    });

    const populatedBooking = await Booking.findById(booking._id)
      .populate(
        "car",
        "name brand images pricePerDay location seats transmission fuelType rating description",
      )
      .populate("user", "fullName email phone");

    res.status(201).json({
      success: true,
      message: "Booking created successfully",

      data: populatedBooking,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

const getMyBookings = async (req, res) => {
  try {
    const bookings = await Booking.find({
      user: req.user._id,
    })
      .populate(
        "car",
        "name brand images pricePerDay location seats transmission fuelType rating description",
      )
      .sort({
        createdAt: -1,
      });

    res.status(200).json({
      success: true,
      count: bookings.length,
      data: bookings,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

const getBookingById = async (req, res) => {
  try {
    const booking = await Booking.findById(req.params.id)
      .populate("car")
      .populate("user", "fullName email phone");

    if (!booking) {
      return res.status(404).json({
        success: false,
        message: "Booking not found",
      });
    }

    const isOwner = booking.user._id.toString() === req.user._id.toString();

    const isAdmin = req.user.role === "admin";

    if (!isOwner && !isAdmin) {
      return res.status(403).json({
        success: false,
        message: "You do not have permission to view this booking",
      });
    }

    res.status(200).json({
      success: true,
      data: booking,
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      message: "Invalid booking id",
    });
  }
};

const cancelBooking = async (req, res) => {
  try {
    const booking = await Booking.findById(req.params.id);

    if (!booking) {
      return res.status(404).json({
        success: false,
        message: "Booking not found",
      });
    }

    if (booking.user.toString() !== req.user._id.toString()) {
      return res.status(403).json({
        success: false,
        message: "You cannot cancel this booking",
      });
    }

    if (booking.status !== "pending" && booking.status !== "confirmed") {
      return res.status(400).json({
        success: false,
        message: "This booking cannot be cancelled",
      });
    }

    booking.status = "cancelled";

    await booking.save();

    res.status(200).json({
      success: true,
      message: "Booking cancelled successfully",
      data: booking,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

const getAllBookings = async (req, res) => {
  try {
    const { status, paymentStatus, search } = req.query;
    const filter = {};

    if (status) {
      if (!bookingStatuses.includes(status)) {
        return res.status(400).json({
          success: false,
          message: "Invalid booking status",
        });
      }
      filter.status = status;
    }

    if (paymentStatus) {
      if (!["unpaid", "paid", "failed", "refunded"].includes(paymentStatus)) {
        return res.status(400).json({
          success: false,
          message: "Invalid payment status",
        });
      }
      filter.paymentStatus = paymentStatus;
    }

    if (search?.trim()) {
      const searchRegex = new RegExp(escapeRegex(search.trim()), "i");
      const [users, cars] = await Promise.all([
        User.find({
          $or: [
            { fullName: searchRegex },
            { email: searchRegex },
            { phone: searchRegex },
          ],
        }).select("_id"),
        Car.find({
          $or: [
            { name: searchRegex },
            { brand: searchRegex },
            { licensePlate: searchRegex },
          ],
        }).select("_id"),
      ]);

      filter.$or = [
        { user: { $in: users.map((user) => user._id) } },
        { car: { $in: cars.map((car) => car._id) } },
      ];

      if (mongoose.Types.ObjectId.isValid(search.trim())) {
        filter.$or.push({ _id: search.trim() });
      }
    }

    const bookings = await Booking.find(filter)
      .populate("car", "name brand licensePlate")
      .populate("user", "fullName email phone")
      .sort({
        createdAt: -1,
      });

    res.status(200).json({
      success: true,
      count: bookings.length,
      data: bookings,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

const updateBookingStatus = async (req, res) => {
  try {
    const { status } = req.body;

    if (!bookingStatuses.includes(status)) {
      return res.status(400).json({
        success: false,
        message: "Invalid booking status",
      });
    }

    const booking = await Booking.findById(req.params.id);

    if (!booking) {
      return res.status(404).json({
        success: false,
        message: "Booking not found",
      });
    }

    const allowedTransitions = {
      pending: ["pending", "confirmed", "cancelled"],
      confirmed: ["confirmed", "ongoing", "cancelled"],
      ongoing: ["ongoing", "completed"],
      completed: ["completed"],
      cancelled: ["cancelled"],
    };

    if (!allowedTransitions[booking.status].includes(status)) {
      return res.status(400).json({
        success: false,
        message: `Cannot change booking status from ${booking.status} to ${status}`,
      });
    }

    booking.status = status;
    await booking.save();

    res.status(200).json({
      success: true,
      message: "Booking status updated",
      data: booking,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

const markBookingAsPaid = async (req, res) => {
  try {
    const booking = await Booking.findById(req.params.id);

    if (!booking) {
      return res.status(404).json({
        success: false,
        message: "Booking not found",
      });
    }

    const isOwner = booking.user.toString() === req.user._id.toString();
    const isAdmin = req.user.role === "admin";

    if (!isOwner && !isAdmin) {
      return res.status(403).json({
        success: false,
        message: "You do not have permission to pay this booking",
      });
    }

    if (booking.status === "cancelled") {
      return res.status(400).json({
        success: false,
        message: "Cancelled booking cannot be paid",
      });
    }

    if (booking.paymentStatus === "paid") {
      return res.status(400).json({
        success: false,
        message: "Booking has already been paid",
      });
    }

    booking.paymentStatus = "paid";
    booking.status = "confirmed";

    await booking.save();

    res.status(200).json({
      success: true,
      message: "Payment completed successfully",
      data: booking,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

module.exports = {
  createBooking,
  getMyBookings,
  getBookingById,
  cancelBooking,
  getAllBookings,
  updateBookingStatus,
  markBookingAsPaid,
};
