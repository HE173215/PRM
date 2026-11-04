const Car = require("../models/Car");
const Booking = require("../models/Booking");

// GET ALL
const getCars = async (req, res) => {
  try {
    const { search, brand, seats } = req.query;

    const filter = {};

    if (search) {
      filter.$or = [
        {
          name: {
            $regex: search,
            $options: "i",
          },
        },
        {
          brand: {
            $regex: search,
            $options: "i",
          },
        },
      ];
    }

    if (brand) {
      filter.brand = brand;
    }

    if (seats) {
      filter.seats = Number(seats);
    }

    const cars = await Car.find(filter).sort({
      createdAt: -1,
    });

    res.status(200).json({
      success: true,
      count: cars.length,
      data: cars,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// GET DETAIL
const getCarById = async (req, res) => {
  try {
    const car = await Car.findById(req.params.id);

    if (!car) {
      return res.status(404).json({
        success: false,
        message: "Car not found",
      });
    }

    res.status(200).json({
      success: true,
      data: car,
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      message: "Invalid car id",
    });
  }
};

// CREATE
const createCar = async (req, res) => {
  try {
    const car = await Car.create(req.body);

    res.status(201).json({
      success: true,
      message: "Car created successfully",
      data: car,
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      message: error.message,
    });
  }
};

// UPDATE
const updateCar = async (req, res) => {
  try {
    const car = await Car.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true,
    });

    if (!car) {
      return res.status(404).json({
        success: false,
        message: "Car not found",
      });
    }

    res.status(200).json({
      success: true,
      message: "Car updated successfully",
      data: car,
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      message: error.message,
    });
  }
};

// DELETE
const deleteCar = async (req, res) => {
  try {
    const car = await Car.findById(req.params.id);

    if (!car) {
      return res.status(404).json({
        success: false,
        message: "Car not found",
      });
    }

    const hasBookingHistory = await Booking.exists({ car: car._id });

    if (hasBookingHistory) {
      return res.status(409).json({
        success: false,
        message: "Car has booking history and cannot be deleted",
      });
    }

    await car.deleteOne();

    res.status(200).json({
      success: true,
      message: "Car deleted successfully",
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      message: error.message,
    });
  }
};

module.exports = {
  getCars,
  getCarById,
  createCar,
  updateCar,
  deleteCar,
};
