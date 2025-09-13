defmodule MimeDescriptionTest do
  use ExUnit.Case

  describe "get/1" do
    test "returns {:ok, description} for known MIME types" do
      assert {:ok, "PDF document"} = MimeDescription.get("application/pdf")
      assert {:ok, "Plain text document"} = MimeDescription.get("text/plain")
      assert {:ok, "HTML document"} = MimeDescription.get("text/html")
      assert {:ok, "JPEG image"} = MimeDescription.get("image/jpeg")
      assert {:ok, "PNG image"} = MimeDescription.get("image/png")
    end

    test "returns {:error, :not_found} for unknown MIME type" do
      assert {:error, :not_found} = MimeDescription.get("unknown/unknown")
      assert {:error, :not_found} = MimeDescription.get("fake/mimetype")
    end

    test "handles edge cases" do
      assert {:error, :not_found} = MimeDescription.get("")
      assert {:error, :not_found} = MimeDescription.get("not-a-mime-type")
    end
  end

  describe "get!/1" do
    test "returns description for known MIME types" do
      assert "PDF document" = MimeDescription.get!("application/pdf")
      assert "Plain text document" = MimeDescription.get!("text/plain")
    end

    test "raises KeyError for unknown MIME type" do
      assert_raise KeyError, ~r/MIME type not found: "unknown\/unknown"/, fn ->
        MimeDescription.get!("unknown/unknown")
      end
    end
  end

  describe "get_with_default/2" do
    test "returns description for known MIME types" do
      assert "PDF document" = MimeDescription.get_with_default("application/pdf")
      assert "Plain text document" = MimeDescription.get_with_default("text/plain", "fallback")
    end

    test "returns default for unknown MIME type" do
      assert "Unknown file type" = MimeDescription.get_with_default("unknown/unknown")
      assert "Custom fallback" = MimeDescription.get_with_default("unknown/unknown", "Custom fallback")
    end

    test "default parameter works correctly" do
      assert "Custom" = MimeDescription.get_with_default("fake/type", "Custom")
      assert "Unknown file type" = MimeDescription.get_with_default("fake/type")
    end
  end

  describe "data integrity" do
    test "data module exists and returns map" do
      assert is_map(MimeDescription.Data.get_all())
    end

    test "data module contains expected MIME types" do
      data = MimeDescription.Data.get_all()

      # Check for common MIME types
      assert Map.has_key?(data, "application/pdf")
      assert Map.has_key?(data, "text/plain")
      assert Map.has_key?(data, "text/html")
      assert Map.has_key?(data, "image/jpeg")
      assert Map.has_key?(data, "image/png")
      assert Map.has_key?(data, "application/json")
      assert Map.has_key?(data, "application/xml")
    end

    test "all descriptions are non-empty strings" do
      data = MimeDescription.Data.get_all()

      Enum.each(data, fn {mime_type, description} ->
        assert is_binary(mime_type)
        assert is_binary(description)
        assert String.length(description) > 0
        refute String.contains?(mime_type, " ")
      end)
    end
  end
end
