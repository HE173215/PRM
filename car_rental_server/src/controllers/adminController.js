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

const paymentStatuses = ["unpaid", "paid", "failed", "refunded"];

const isValidId = (id) => mongoose.Types.ObjectId.isValid(id);

const getDashboard = async (req, res) => {
  try {
    const [
      totalUsers,
      totalCars,
      availableCars,
      rentedCars,
      maintenanceCars,
      totalBookings,
      bookingCounts,
      revenueResult,
    ] = await Promise.all([
      User.countDocuments(),
      Car.countDocuments(),
      Car.countDocuments({ status: "available" }),
      Car.countDocuments({ status: "rented" }),
      Car.countDocuments({ status: "maintenance" }),
      Booking.countDocuments(),
      Booking.aggregate([
        {
          $group: {
            _id: "$status",
            count: { $sum: 1 },
          },
        },
      ]),
      Booking.aggregate([
        { $match: { paymentStatus: "paid", status: { $ne: "cancelled" } } },
        {
          $group: {
            _id: null,
            total: { $sum: "$totalAmount" },
          },
        },
      ]),
    ]);

    const countsByStatus = Object.fromEntries(
      bookingStatuses.map((status) => [status, 0]),
    );

    bookingCounts.forEach(({ _id, count }) => {
      if (_id in countsByStatus) {
        countsByStatus[_id] = count;
      }
    });

    res.status(200).json({
      success: true,
      data: {
        totalUsers,
        totalCars,
        availableCars,
        rentedCars,
        maintenanceCars,
        totalBookings,
        pendingBookings: countsByStatus.pending,
        confirmedBookings: countsByStatus.confirmed,
        ongoingBookings: countsByStatus.ongoing,
        completedBookings: countsByStatus.completed,
        cancelledBookings: countsByStatus.cancelled,
        totalRevenue: revenueResult[0]?.total || 0,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

const getRevenueReport = async (req, res) => {
  try {
    const year = Number(req.query.year || new Date().getFullYear());

    if (!Number.isInteger(year) || year < 1970 || year > 2100) {
      return res.status(400).json({
        success: false,
        message: "Invalid year",
      });
    }

    const startDate = new Date(Date.UTC(year, 0, 1));
    const endDate = new Date(Date.UTC(year + 1, 0, 1));
    const revenue = await Booking.aggregate([
      {
        $match: {
          paymentStatus: "paid",
          status: { $ne: "cancelled" },
          createdAt: { $gte: startDate, $lt: endDate },
        },
      },
      {
        $group: {
          _id: { $month: "$createdAt" },
          revenue: { $sum: "$totalAmount" },
        },
      },
      { $sort: { _id: 1 } },
    ]);

    const revenueByMonth = Array.from({ length: 12 }, (_, index) => ({
      month: index + 1,
      revenue: revenue.find((item) => item._id === index + 1)?.revenue || 0,
    }));

    res.status(200).json({
      success: true,
      year,
      data: revenueByMonth,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

const getBookingReport = async (req, res) => {
  try {
    const [total, statusCounts, monthlyCounts] = await Promise.all([
      Booking.countDocuments(),
      Booking.aggregate([
        {
          $group: {
            _id: "$status",
            count: { $sum: 1 },
          },
        },
      ]),
      Booking.aggregate([
        {
          $group: {
            _id: {
              year: { $year: "$createdAt" },
              month: { $month: "$createdAt" },
            },
            count: { $sum: 1 },
          },
        },
        { $sort: { "_id.year": 1, "_id.month": 1 } },
      ]),
    ]);

    const byStatus = Object.fromEntries(
      bookingStatuses.map((status) => [status, 0]),
    );
    statusCounts.forEach(({ _id, count }) => {
      if (_id in byStatus) {
        byStatus[_id] = count;
      }
    });

    res.status(200).json({
      success: true,
      data: {
        total,
        byStatus,
        byMonth: monthlyCounts.map(({ _id, count }) => ({
          year: _id.year,
          month: _id.month,
          count,
        })),
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

const getTopRentedCars = async (req, res) => {
  try {
    const limit = Number(req.query.limit || 5);

    if (!Number.isInteger(limit) || limit < 1 || limit > 100) {
      return res.status(400).json({
        success: false,
        message: "Limit must be an integer between 1 and 100",
      });
    }

    const cars = await Booking.aggregate([
      { $match: { status: { $ne: "cancelled" } } },
      {
        $group: {
          _id: "$car",
          bookingCount: { $sum: 1 },
          revenue: {
            $sum: {
              $cond: [{ $eq: ["$paymentStatus", "paid"] }, "$totalAmount", 0],
            },
          },
        },
      },
      { $sort: { bookingCount: -1, revenue: -1 } },
      { $limit: limit },
      {
        $lookup: {
          from: "cars",
          localField: "_id",
          foreignField: "_id",
          as: "car",
        },
      },
      { $unwind: { path: "$car", preserveNullAndEmptyArrays: true } },
      {
        $project: {
          _id: 0,
          carId: "$_id",
          name: { $ifNull: ["$car.name", "Unknown car"] },
          bookingCount: 1,
          revenue: 1,
        },
      },
    ]);

    res.status(200).json({
      success: true,
      data: cars,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

const getUsers = async (req, res) => {
  try {
    const users = await User.find()
      .select("fullName email phone role status createdAt updatedAt")
      .sort({ createdAt: -1 });

    res.status(200).json({
      success: true,
      count: users.length,
      data: users,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

const getUserById = async (req, res) => {
  try {
    if (!isValidId(req.params.id)) {
      return res.status(400).json({
        success: false,
        message: "Invalid user id",
      });
    }

    const user = await User.findById(req.params.id).select(
      "fullName email phone role status createdAt updatedAt",
    );

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    res.status(200).json({
      success: true,
      data: user,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

const updateUserStatus = async (req, res) => {
  try {
    const { status } = req.body;

    if (!["active", "blocked"].includes(status)) {
      return res.status(400).json({
        success: false,
        message: "Invalid user status",
      });
    }

    if (
      status === "blocked" &&
      req.params.id.toString() === req.user._id.toString()
    ) {
      return res.status(400).json({
        success: false,
        message: "Admin cannot block own account.",
      });
    }

    if (!isValidId(req.params.id)) {
      return res.status(400).json({
        success: false,
        message: "Invalid user id",
      });
    }

    const user = await User.findByIdAndUpdate(
      req.params.id,
      { status },
      { new: true, runValidators: true },
    ).select("fullName email phone role status createdAt updatedAt");

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    res.status(200).json({
      success: true,
      message: "User status updated successfully",
      data: user,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

const getPayments = async (req, res) => {
  try {
    const filter = {};

    if (req.query.status) {
      if (!paymentStatuses.includes(req.query.status)) {
        return res.status(400).json({
          success: false,
          message: "Invalid payment status",
        });
      }
      filter.paymentStatus = req.query.status;
    }

    const payments = await Booking.find(filter)
      .select(
        "_id user car totalAmount paymentStatus status createdAt updatedAt",
      )
      .populate("user", "fullName email")
      .populate("car", "name brand licensePlate")
      .sort({ updatedAt: -1 });

    res.status(200).json({
      success: true,
      count: payments.length,
      data: payments,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

const getPaymentById = async (req, res) => {
  try {
    if (!isValidId(req.params.id)) {
      return res.status(400).json({
        success: false,
        message: "Invalid booking id",
      });
    }

    const payment = await Booking.findById(req.params.id)
      .select(
        "_id user car totalAmount paymentStatus status createdAt updatedAt",
      )
      .populate("user", "fullName email")
      .populate("car", "name brand licensePlate");

    if (!payment) {
      return res.status(404).json({
        success: false,
        message: "Payment not found",
      });
    }

    res.status(200).json({
      success: true,
      data: payment,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

module.exports = {
  getDashboard,
  getRevenueReport,
  getBookingReport,
  getTopRentedCars,
  getUsers,
  getUserById,
  updateUserStatus,
  getPayments,
  getPaymentById,
};
