-- ARCHBRAIN Database Schema
-- Targeting PostgreSQL

-- Enable UUID extension if available
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users Table
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(50) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(50) DEFAULT 'user', -- 'user', 'admin'
    subscription_plan VARCHAR(50) DEFAULT 'free', -- 'free', 'premium', 'business', 'enterprise'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Devices Table
CREATE TABLE IF NOT EXISTS devices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    imei VARCHAR(100) UNIQUE NOT NULL,
    model VARCHAR(255) NOT NULL,
    os_version VARCHAR(100) NOT NULL,
    battery_level INT DEFAULT 100,
    status VARCHAR(50) DEFAULT 'online', -- 'online', 'offline', 'lost'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tracking History Table (GPS points)
CREATE TABLE IF NOT EXISTS tracking_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    device_id UUID REFERENCES devices(id) ON DELETE CASCADE,
    latitude DECIMAL(9,6) NOT NULL,
    longitude DECIMAL(9,6) NOT NULL,
    speed REAL DEFAULT 0.0,
    recorded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- MDM Commands Table (Queue for lock/wipe)
CREATE TABLE IF NOT EXISTS mdm_commands (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    device_id UUID REFERENCES devices(id) ON DELETE CASCADE,
    command_type VARCHAR(50) NOT NULL, -- 'lock', 'wipe', 'alert'
    payload JSONB,
    status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'sent', 'executed', 'failed'
    admin_id UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- NDPR Consent Records Table
CREATE TABLE IF NOT EXISTS consent_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    device_id UUID REFERENCES devices(id) ON DELETE CASCADE,
    ip_address VARCHAR(45) NOT NULL,
    consent_given BOOLEAN DEFAULT TRUE,
    consented_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    withdrawn_at TIMESTAMP WITH TIME ZONE
);

-- MDM Security Policies Table
CREATE TABLE IF NOT EXISTS policies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    device_id UUID REFERENCES devices(id) ON DELETE CASCADE UNIQUE,
    block_whatsapp BOOLEAN DEFAULT FALSE,
    block_games BOOLEAN DEFAULT FALSE,
    pin_required BOOLEAN DEFAULT TRUE,
    location_mandatory BOOLEAN DEFAULT TRUE,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexing for fast location lookup
CREATE INDEX IF NOT EXISTS idx_tracking_device_recorded ON tracking_history(device_id, recorded_at DESC);
CREATE INDEX IF NOT EXISTS idx_mdm_pending ON mdm_commands(device_id, status) WHERE status = 'pending';
