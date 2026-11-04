const mongoose = require("mongoose");

const carSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
      trim: true,
    },

    brand: {
      type: String,
      required: true,
      trim: true,
    },

    model: {
      type: String,
      trim: true,
    },

    year: {
      type: Number,
      min: 1886,
      max: 2100,
    },

    licensePlate: {
      type: String,
      required: true,
      unique: true,
      trim: true,
    },

    seats: {
      type: Number,
      required: true,
      min: 1,
    },

    transmission: {
      type: String,
      enum: ["Automatic", "Manual"],
      required: true,
    },

    fuelType: {
      type: String,
      enum: ["Gasoline", "Diesel", "Electric", "Hybrid"],
      required: true,
    },

    pricePerDay: {
      type: Number,
      required: true,
      min: 0,
    },

    location: {
      type: String,
      required: true,
    },

    description: {
      type: String,
      default: "",
    },

    images: {
      type: [String],
      default: [],
    },

    rating: {
      type: Number,
      min: 0,
      max: 5,
      default: 0,
    },

    status: {
      type: String,
      enum: ["available", "rented", "maintenance"],
      default: "available",
    },
  },
  {
    timestamps: true,
  },
);

module.exports = mongoose.model("Car", carSchema);
