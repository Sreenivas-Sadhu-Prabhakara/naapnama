package backend

import (
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"
)

type memStore struct{ items []Record }

func (m *memStore) Save(r Record) (Record, error) {
	r.ID = int64(len(m.items) + 1)
	m.items = append([]Record{r}, m.items...)
	return r, nil
}
func (m *memStore) List(limit int) ([]Record, error) { return m.items, nil }

func TestOverdue(t *testing.T) {
	today := time.Date(2026, 8, 18, 0, 0, 0, 0, time.UTC)
	if !(Order{DueDate: "2026-08-15"}).Overdue(today) {
		t.Fatal("past due pending order should be overdue")
	}
	if (Order{DueDate: "2026-08-25"}).Overdue(today) {
		t.Fatal("future order not overdue")
	}
	if (Order{DueDate: "2026-08-15", Delivered: true}).Overdue(today) {
		t.Fatal("delivered order never overdue")
	}
}

func TestValidate(t *testing.T) {
	if err := (Order{Customer: "A", Garment: "shirt", DueDate: "2026-08-25"}).Validate(); err != nil {
		t.Fatalf("valid rejected: %v", err)
	}
	for i, bad := range []Order{{Garment: "x"}, {Customer: "A"}, {Customer: "A", Garment: "x", DueDate: "25-08-2026"}} {
		if err := bad.Validate(); err == nil {
			t.Fatalf("bad %d accepted", i)
		}
	}
}

func TestLogEndpoint(t *testing.T) {
	srv := NewServer(&memStore{})
	rec := httptest.NewRecorder()
	srv.ServeHTTP(rec, httptest.NewRequest(http.MethodPost, "/log",
		strings.NewReader(`{"customer":"Meena","garment":"blouse","measurements":"chest 38","dueDate":"2026-08-25"}`)))
	if rec.Code != http.StatusCreated {
		t.Fatalf("log %d", rec.Code)
	}
}
