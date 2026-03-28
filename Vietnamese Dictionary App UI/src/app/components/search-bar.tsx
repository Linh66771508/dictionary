import { Search, X } from "lucide-react";

interface SearchBarProps {
  value: string;
  onChange: (value: string) => void;
  onSearch?: () => void;
  placeholder?: string;
}

export function SearchBar({ value, onChange, onSearch, placeholder = "Tìm từ..." }: SearchBarProps) {
  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSearch?.();
  };

  return (
    <form onSubmit={handleSubmit} className="w-full">
      <div className="relative bg-white rounded-lg border-2 border-blue-200 focus-within:border-blue-500 transition-colors shadow-sm">
        <Search className="absolute left-4 top-1/2 -translate-y-1/2 size-5 text-blue-500" />
        <input
          type="text"
          value={value}
          onChange={(e) => onChange(e.target.value)}
          placeholder={placeholder}
          className="w-full pl-12 pr-12 py-3.5 bg-transparent rounded-lg border-0 outline-none text-gray-900 placeholder:text-gray-400"
        />
        {value && (
          <button
            type="button"
            onClick={() => onChange("")}
            className="absolute right-4 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
          >
            <X className="size-5" />
          </button>
        )}
      </div>
    </form>
  );
}
