package backend

import (
	"encoding/json"
	"fmt"
	"time"
)

// Order is a garment order with the customer's measurements and a promised
// delivery date. Measurements ARE the production pipeline.
type Order struct {
	Customer     string  `json:"customer"`
	Garment      string  `json:"garment"`
	Measurements string  `json:"measurements"` // e.g. "chest 40, waist 34, length 28"
	DueDate      string  `json:"dueDate"`      // ISO date, e.g. 2026-08-25
	Delivered    bool    `json:"delivered"`
}

// Validate reports whether the Order is well formed.
func (o Order) Validate() error {
	if o.Customer == "" {
		return fmt.Errorf("customer is required")
	}
	if o.Garment == "" {
		return fmt.Errorf("garment is required")
	}
	if o.DueDate != "" {
		if _, err := time.Parse("2006-01-02", o.DueDate); err != nil {
			return fmt.Errorf("due date must be YYYY-MM-DD")
		}
	}
	return nil
}

// Overdue reports whether a pending order's due date is before `today`.
func (o Order) Overdue(today time.Time) bool {
	if o.Delivered || o.DueDate == "" {
		return false
	}
	due, err := time.Parse("2006-01-02", o.DueDate)
	if err != nil {
		return false
	}
	return due.Before(today)
}

// Summary counts the order board.
type Summary struct {
	Pending   int `json:"pending"`
	Delivered int `json:"delivered"`
}

// Summarize counts pending vs delivered orders.
func Summarize(records []Record) Summary {
	var s Summary
	for _, r := range records {
		if r.Label == "delivered" {
			s.Delivered++
		} else {
			s.Pending++
		}
	}
	return s
}

// parseEntry decodes+validates an order; headline 0 (no money), label the state.
func parseEntry(raw []byte) (float64, string, error) {
	var o Order
	if err := json.Unmarshal(raw, &o); err != nil {
		return 0, "", fmt.Errorf("invalid json")
	}
	if err := o.Validate(); err != nil {
		return 0, "", err
	}
	label := "pending"
	if o.Delivered {
		label = "delivered"
	}
	return 0, label, nil
}
